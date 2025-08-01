`timescale 1ns / 1ps
`default_nettype none

module tb_bonus;

    // Clocks 
    reg clk = 0;
    reg clk1 = 0;
    reg clk2 = 0;
    always #5  clk  = ~clk;   // 10 ns period system clock
    always #7  clk1 = ~clk1;  
    always #11 clk2 = ~clk2;  

    // Reset
    reg rst = 1;

    // (inputs to imu_to_quat_delta) 
    reg signed [15:0] wx = 0, wy = 0, wz = 0;

    // Fixed timestep for integration 
    reg [31:0] dt = 32'd10000;

    //  Registers for previous quaternion 
    reg signed [15:0] q0p = 16'sd32767;  // Q15 fixed-point for 1.0
    reg signed [15:0] q1p = 0;
    reg signed [15:0] q2p = 0;
    reg signed [15:0] q3p = 0;

    // Wires for outputs from imu_to_quat_delta
    wire signed [15:0] dq0, dq1, dq2, dq3;

    // Wires for outputs from quaternion multiplier 
    wire signed [31:0] q0_new, q1_new, q2_new, q3_new;

    // Instantiate IMU-to-quaternion delta module
    imu_to_quat_delta imu_to_quat_inst (
        .clk(clk),
        .rst(rst),
        .wx(wx), .wy(wy), .wz(wz),
        .dt(dt),
        .dq0(dq0), .dq1(dq1), .dq2(dq2), .dq3(dq3)
    );

    // Instantiate quaternion multiplier pipeline 
    direct_pipelined quat_mult_inst (
        .clk1(clk1),
        .clk2(clk2),
        .rst(rst),
        .a1(q0p), .b1(q1p), .c1(q2p), .d1(q3p),
        .a2(dq0), .b2(dq1), .c2(dq2), .d2(dq3),
        .r1(q0_new), .r2(q1_new), .r3(q2_new), .r4(q3_new)
    );

    // Reset and IMU stimulation sequence
    initial begin
        $display("Time(ns)\t q0_new \t q1_new \t q2_new \t q3_new \t | dq0 \t dq1 \t dq2 \t dq3 \t | q0p \t q1p \t q2p \t q3p");
        
        rst = 1;      // Assert reset
        #30;
        rst = 0;      // Release reset

       
        // Rotate about X axis
        wx = 16'sd15000; wy = 0; wz = 0;
        #150;

        // Rotate about Y axis
        wx = 0; wy = 16'sd15000; wz = 0;
        #150;

        // Rotate about Z axis
        wx = 0; wy = 0; wz = 16'sd15000;
        #150;

        // Stop rotation
        wx = 0; wy = 0; wz = 0;
        #200;

        $finish;
    end

    // Capture multiplier output and update previous quaternion values for next cycle
    always @(posedge clk2) begin
        if (rst) begin
            q0p <= 16'sd32767;  // Reset to identity quaternion scalar
            q1p <= 0;
            q2p <= 0;
            q3p <= 0;
        end else begin
            // Truncate multiplier 32-bit results to 16-bit for feedback
            q0p <= q0_new[15:0];
            q1p <= q1_new[15:0];
            q2p <= q2_new[15:0];
            q3p <= q3_new[15:0];
        end
    end

    // Display debug info on each clk2 rising edge for monitoring
    always @(posedge clk2) begin
        if(!rst) begin
            $display("%0t\t %d\t %d\t %d\t %d\t | %d\t %d\t %d\t %d\t | %d\t %d\t %d\t %d", 
                $time,
                q0_new, q1_new, q2_new, q3_new,
                dq0, dq1, dq2, dq3,
                q0p, q1p, q2p, q3p
            );
        end
    end

endmodule

`default_nettype wire
