`timescale 1ns / 1ps
`default_nettype none

module tb_bonus;

    // Clock generation
    reg clk = 0;
    always #5 clk = ~clk; // 10 ns period

    // Reset and inputs
    reg rst;
    reg signed [15:0] wx, wy, wz;
    reg [31:0] dt;

    // Quaternion state
    reg signed [15:0] q0 = 16'sd32767, q1 = 0, q2 = 0, q3 = 0;
    wire signed [31:0] q0_new, q1_new, q2_new, q3_new;
    wire signed [15:0] q0_scaled, q1_scaled, q2_scaled, q3_scaled;

    // IMU delta quaternion output
    wire signed [15:0] dq0, dq1, dq2, dq3;

    // Instantiate IMU delta module
    imu_to_quat_delta imu (
        .clk(clk), .rst(rst),
        .wx(wx), .wy(wy), .wz(wz),
        .dt(dt),
        .dq0(dq0), .dq1(dq1), .dq2(dq2), .dq3(dq3)
    );

    // Instantiate quaternion multiplication (direct pipelined)
    direct_pipelined mult (
        .clk1(clk), .clk2(clk), .rst(rst),
        .a1(q0), .b1(q1), .c1(q2), .d1(q3),      // Previous quaternion
        .a2(dq0), .b2(dq1), .c2(dq2), .d2(dq3),  // Delta quaternion
        .r1(q0_new), .r2(q1_new), .r3(q2_new), .r4(q3_new)
    );

    // Feedback loop to update quaternion
    reg seen_nonzero = 0;
    always @(posedge clk) begin
        if (q0_new != 0 || q1_new != 0 || q2_new != 0 || q3_new != 0)
            seen_nonzero <= 1;

        if (seen_nonzero) begin
            q0 <= q0_new[30:15]; // Downscale from Q30 to Q15
            q1 <= q1_new[30:15];
            q2 <= q2_new[30:15];
            q3 <= q3_new[30:15];
        end
    end

    assign q0_scaled = q0;
    assign q1_scaled = q1;
    assign q2_scaled = q2;
    assign q3_scaled = q3;

    // Main test sequence
    initial begin
        $display("=== Quaternion Rotation Results ===");

        // Reset system
        rst = 1;
        #30;
        rst = 0;

        dt = 32'd100000;

        // -------- Rotate about X --------
        wx = 16'sd15000; wy = 0; wz = 0;
        #300;
        $display("Rot X => q: %d %d %d %d", q0_scaled, q1_scaled, q2_scaled, q3_scaled);

        // -------- Rotate about Y --------
        wx = 0; wy = 16'sd15000; wz = 0;
        #300;
        $display("Rot Y => q: %d %d %d %d", q0_scaled, q1_scaled, q2_scaled, q3_scaled);

        // -------- Rotate about Z --------
        wx = 0; wy = 0; wz = 16'sd15000;
        #300;
        $display("Rot Z => q: %d %d %d %d", q0_scaled, q1_scaled, q2_scaled, q3_scaled);

        $finish;
    end

endmodule
