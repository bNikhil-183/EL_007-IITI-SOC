`timescale 1ns / 1ps

module qftb;
    reg clk;
    reg rst;

    reg signed [15:0] a0, a1, a2, a3;
    reg signed [15:0] b0, b1, b2, b3;

    wire signed [31:0] q0, q1, q2, q3;

    qf uut (
        .clk(clk),
        .rst(rst),
        .a0(a0), .a1(a1), .a2(a2), .a3(a3),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3),
        .q0(q0), .q1(q1), .q2(q2), .q3(q3)
    );

   always #5 clk = ~clk;
	
    // Task to apply reset and wait
    task reset_and_wait;
    begin
        rst = 1;
        @(posedge clk); @(posedge clk);
        rst = 0;
    end
    endtask

    task run_test(
        input signed [15:0] ta0, ta1, ta2, ta3,
        input signed [15:0] tb0, tb1, tb2, tb3,
        input signed [31:0] exp_q0, exp_q1, exp_q2, exp_q3,
        input [7:0] test_num
    );
    begin
        reset_and_wait();

        a0 = ta0; a1 = ta1; a2 = ta2; a3 = ta3;
        b0 = tb0; b1 = tb1; b2 = tb2; b3 = tb3;

        repeat (10) @(posedge clk);

        $display("\nTest %0d:", test_num);
        $display("Q0 = %d (Expected:%d) ", q0, exp_q0);
        $display("Q1 = %d (Expected:%d) ", q1, exp_q1);
        $display("Q2 = %d (Expected:%d) ", q2, exp_q2);
        $display("Q3 = %d (Expected:%d) ", q3, exp_q3);
    end
    endtask

    initial begin
        clk = 0;

        // Test 1: Q1 = 1 + 2i + 3j + 4k; Q2 = 5 + 6i + 7j + 8k
        run_test(
            16'sd1, 16'sd2, 16'sd3, 16'sd4,
            16'sd5, 16'sd6, 16'sd7, 16'sd8,
            -60, 12, 30, 24,
            1
        );

        // Test 2: Q1 = 1 + 0i + 0j + 0k; Q2 = 9 -2i + 1j + 3k
        run_test(
            16'sd1, 16'sd0, 16'sd0, 16'sd0,
            16'sd9, -16'sd2, 16'sd1, 16'sd3,
            9, -2, 1, 3,
            2
        );

        // Test 3: Q1 = -3 + 2i -1j + 4k; Q2 = 2 + 0i + 1j -2k
        run_test(
            -16'sd3, 16'sd2, -16'sd1, 16'sd4,
            16'sd2, 16'sd0, 16'sd1, -16'sd2,
            3, 2, -1, 16,
            3
        );

        $display("\n-- Test Completed --");
        $finish;
    end
endmodule
