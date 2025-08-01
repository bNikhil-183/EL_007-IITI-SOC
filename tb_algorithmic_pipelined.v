`timescale 1ns / 1ps

module tb_algorithmic_pipelined;

    // Inputs
    reg clk1 = 0;
    reg clk2 = 0;
    reg rst;
    reg start;
    reg signed [15:0] a0, a1, a2, a3;
    reg signed [15:0] b0, b1, b2, b3;

    // Outputs
    wire signed [31:0] q0, q1, q2, q3;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    algorithmic_multiplication_pipelined uut (
        .clk1(clk1),
        .clk2(clk2),
        .rst(rst),
        .start(start),
        .a0(a0), .a1(a1), .a2(a2), .a3(a3),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3),
        .q0(q0), .q1(q1), .q2(q2), .q3(q3),
        .done(done)
    );

    // Clock generation
    always #5 clk1 = ~clk1;  // 100 MHz
    always #7 clk2 = ~clk2;  // Non-overlapping ~71 MHz

    initial begin
        $display("Starting Quaternion Multiplication Testbench");
        $dumpfile("algorithmic_pipeline.vcd");
        $dumpvars(0, tb_algorithmic_pipelined);

        // Reset
        rst = 1;
        start = 0;
        #20 rst = 0;

        // Apply inputs
        a0 = 16'sd1; a1 = 16'sd2; a2 = 16'sd3; a3 = 16'sd4;
        b0 = 16'sd5; b1 = 16'sd6; b2 = 16'sd7; b3 = 16'sd8;

        // Trigger start pulse
        #10 start = 1;
        #10 start = 0;

        // Wait for result
        wait (done == 1);

        // Display output
        $display("\nQuaternion Result:");
        $display("q0 = %d", q0);
        $display("q1 = %d", q1);
        $display("q2 = %d", q2);
        $display("q3 = %d", q3);

        #50;
        $finish;
    end

endmodule
