`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2025 11:21:06 PM
// Design Name: 
// Module Name: tb_direct
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_direct;

    // Inputs
    reg clk;
    reg rst;
    reg load;
    reg compute;
    reg signed [15:0] a1, b1, c1, d1;
    reg signed [15:0] a2, b2, c2, d2;

    // Outputs
    wire [31:0] r1, r2, r3, r4;
    wire valid;

    // Instantiate DUT
    direct_multiplication uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .compute(compute),
        .valid(valid),
        .a1(a1), .b1(b1), .c1(c1), .d1(d1),
        .a2(a2), .b2(b2), .c2(c2), .d2(d2),
        .r1(r1), .r2(r2), .r3(r3), .r4(r4)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Task for running one test case
    task run_test(
        input signed [15:0] _a1, _b1, _c1, _d1,
        input signed [15:0] _a2, _b2, _c2, _d2
    );
    begin
        // Apply input values
        @(posedge clk);
        load <= 1;
        a1 <= _a1; b1 <= _b1; c1 <= _c1; d1 <= _d1;
        a2 <= _a2; b2 <= _b2; c2 <= _c2; d2 <= _d2;
        @(posedge clk);
        load <= 0;

        // Trigger computation
        compute <= 1;
        @(posedge clk);
        compute <= 0;

        // Wait for results to stabilize
        repeat (4) @(posedge clk);

        // Display results
        $display("Inputs:");
        $display("A1=%d B1=%d C1=%d D1=%d", _a1, _b1, _c1, _d1);
        $display("A2=%d B2=%d C2=%d D2=%d", _a2, _b2, _c2, _d2);
        $display("Output valid = %b", valid);
        $display("R1 = %d, R2 = %d, R3 = %d, R4 = %d\n", r1, r2, r3, r4);
    end
    endtask

    initial begin
        // Initial state
        rst = 1;
        load = 0;
        compute = 0;
        a1 = 0; b1 = 0; c1 = 0; d1 = 0;
        a2 = 0; b2 = 0; c2 = 0; d2 = 0;

        // Reset
        #10 rst = 0;

        // Run multiple test cases
        #10 run_test(16'sd1, 16'sd2, 16'sd3, 16'sd4, 16'sd5, 16'sd6, 16'sd7, 16'sd8);     // Case 1: All positive
        #10 run_test(-16'sd1, 16'sd2, -16'sd3, 16'sd4, 16'sd5, -16'sd6, 16'sd7, -16'sd8); // Case 2: Mixed signs
        #10 run_test(-16'sd5, -16'sd6, -16'sd7, -16'sd8, -16'sd1, -16'sd2, -16'sd3, -16'sd4); // Case 3: All negative
        #10 run_test(16'sd10, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd0, 16'sd0, 16'sd0);     // Case 4: Sparse input (a1=10 * a2=1)

        #50 $finish;
    end

endmodule
