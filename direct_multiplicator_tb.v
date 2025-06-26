`timescale 1ns / 1ps

module dirtb;

    reg signed [15:0] a1, b1, c1, d1;
    reg signed [15:0] a2, b2, c2, d2;

    wire [31:0] r1, r2, r3, r4;

    direct uut (
        .a1(a1), .b1(b1), .c1(c1), .d1(d1),
        .a2(a2), .b2(b2), .c2(c2), .d2(d2),
        .r1(r1), .r2(r2), .r3(r3), .r4(r4)
    );

    initial begin
        // Monitor to show signal changes during simulation
        $monitor("T=%0t ns | Q1 = (%0d, %0d, %0d, %0d), Q2 = (%0d, %0d, %0d, %0d) => Result = (%0d, %0d, %0d, %0d)",
                 $time, a1, b1, c1, d1, a2, b2, c2, d2,
                 $signed(r1), $signed(r2), $signed(r3), $signed(r4));

        // TC1
        {a1, b1, c1, d1, a2, b2, c2, d2} = 128'd0;
        #10;
        $display("TC1: (%0d,%0d,%0d,%0d)*(%0d,%0d,%0d,%0d) = (%0d,%0d,%0d,%0d), Expected: (0,0,0,0)",
                 a1, b1, c1, d1, a2, b2, c2, d2,
                 $signed(r1), $signed(r2), $signed(r3), $signed(r4));

        // TC2
        a1 = 16'sd1; b1 = 0; c1 = 0; d1 = 0;
        a2 = 16'sd1; b2 = 0; c2 = 0; d2 = 0;
        #10;
        $display("TC2: (%0d,%0d,%0d,%0d)*(%0d,%0d,%0d,%0d) = (%0d,%0d,%0d,%0d), Expected: (1,0,0,0)",
                 a1, b1, c1, d1, a2, b2, c2, d2,
                 $signed(r1), $signed(r2), $signed(r3), $signed(r4));

        // TC3
        a1 = 0; b1 = 16'sd1; c1 = 0; d1 = 0;
        a2 = 0; b2 = 16'sd1; c2 = 0; d2 = 0;
        #10;
        $display("TC3: (%0d,%0d,%0d,%0d)*(%0d,%0d,%0d,%0d) = (%0d,%0d,%0d,%0d), Expected: (-1,0,0,0)",
                 a1, b1, c1, d1, a2, b2, c2, d2,
                 $signed(r1), $signed(r2), $signed(r3), $signed(r4));

        // TC4
        a1 = 16'sd2; b1 = 16'sd3; c1 = -16'sd4; d1 = 16'sd1;
        a2 = 16'sd1; b2 = 0; c2 = 0; d2 = 0;
        #10;
        $display("TC4: (%0d,%0d,%0d,%0d)*(%0d,%0d,%0d,%0d) = (%0d,%0d,%0d,%0d), Expected: (2,3,-4,1)",
                 a1, b1, c1, d1, a2, b2, c2, d2,
                 $signed(r1), $signed(r2), $signed(r3), $signed(r4));

        // TC5
        a1 = -16'sd5; b1 = 16'sd2; c1 = 16'sd1; d1 = -16'sd3;
        a2 = 16'sd4; b2 = -16'sd2; c2 = 16'sd2; d2 = 16'sd1;
        #10;
        $display("TC5: (%0d,%0d,%0d,%0d)*(%0d,%0d,%0d,%0d) = (%0d,%0d,%0d,%0d), Expected: (-15,25,-2,-11)",
                 a1, b1, c1, d1, a2, b2, c2, d2,
                 $signed(r1), $signed(r2), $signed(r3), $signed(r4));

        // TC6
        a1 = 16'sd7; b1 = -16'sd3; c1 = 16'sd8; d1 = 16'sd2;
        a2 = -16'sd4; b2 = 16'sd6; c2 = -16'sd5; d2 = 16'sd3;
        #10;
        $display("TC6: (%0d,%0d,%0d,%0d)*(%0d,%0d,%0d,%0d) = (%0d,%0d,%0d,%0d), Expected: (24,88,-46,-20)",
                 a1, b1, c1, d1, a2, b2, c2, d2,
                 $signed(r1), $signed(r2), $signed(r3), $signed(r4));

        $finish;
    end

endmodule
