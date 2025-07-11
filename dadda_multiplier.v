`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2025 00:55:04
// Design Name: 
// Module Name: dadda_multiplier
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


module half_adder(
    input a, b,
    output sum, carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule

module full_adder(
    input a, b, cin,
    output sum, carry
);
    assign sum = a ^ b ^ cin;
    assign carry = (a & b) | (b & cin) | (a & cin);
endmodule

module ripple_carry_adder_32bit(
    input [31:0] A,
    input [31:0] B,
    output [31:0] Sum
);
    wire [31:0] carry;

    half_adder ha (
        .a(A[0]), .b(B[0]), .sum(Sum[0]), .carry(carry[0])
    );

    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin: full_adders
            full_adder fa (
                .a(A[i]), .b(B[i]), .cin(carry[i-1]), .sum(Sum[i]), .carry(carry[i])
            );
        end
    endgenerate
endmodule

module carry_lookahead_adder_32bit(
    input [31:0] A,
    input [31:0] B,
    output [31:0] Sum
);
    wire [31:0] G, P, C;
    assign C[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: cla_gen
            assign G[i] = A[i] & B[i];
            assign P[i] = A[i] ^ B[i];
        end
    endgenerate

    generate
        for (i = 1; i < 32; i = i + 1) begin: carry_gen
            assign C[i] = G[i-1] | (P[i-1] & C[i-1]);
        end
    endgenerate

    generate
        for (i = 0; i < 32; i = i + 1) begin: sum_gen
            assign Sum[i] = P[i] ^ C[i];
        end
    endgenerate
endmodule

module dadda_multiplier(
    input [15:0] A,
    input [15:0] B,
    output [31:0] P
);
    wire [15:0] pp [15:0];
    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin: gen_pp
            for (j = 0; j < 16; j = j + 1) begin: gen_bit
                assign pp[i][j] = A[j] & B[i];
            end
        end
    endgenerate

    wire [31:0] sum [0:255];
    generate
        for (i = 0; i < 16; i = i + 1) begin: gen_shifted_pp
            for (j = 0; j < 16; j = j + 1) begin: gen_shift
                assign sum[i * 16 + j] = pp[i][j] << (i + j);
            end
        end
    endgenerate

    wire [31:0] s1 [0:127];
    generate
        for (i = 0; i < 128; i = i + 1) begin: s1_add
            ripple_carry_adder_32bit adder(.A(sum[2*i]), .B(sum[2*i+1]), .Sum(s1[i]));
        end
    endgenerate

    wire [31:0] s2 [0:63];
    generate
        for (i = 0; i < 64; i = i + 1) begin: s2_add
            ripple_carry_adder_32bit adder(.A(s1[2*i]), .B(s1[2*i+1]), .Sum(s2[i]));
        end
    endgenerate

    wire [31:0] s3 [0:31];
    generate
        for (i = 0; i < 32; i = i + 1) begin: s3_add
            ripple_carry_adder_32bit adder(.A(s2[2*i]), .B(s2[2*i+1]), .Sum(s3[i]));
        end
    endgenerate

    wire [31:0] s4 [0:15];
    generate
        for (i = 0; i < 16; i = i + 1) begin: s4_add
            ripple_carry_adder_32bit adder(.A(s3[2*i]), .B(s3[2*i+1]), .Sum(s4[i]));
        end
    endgenerate

    wire [31:0] s5 [0:7];
    generate
        for (i = 0; i < 8; i = i + 1) begin: s5_add
            ripple_carry_adder_32bit adder(.A(s4[2*i]), .B(s4[2*i+1]), .Sum(s5[i]));
        end
    endgenerate

    wire [31:0] s6 [0:3];
    generate
        for (i = 0; i < 4; i = i + 1) begin: s6_add
            carry_lookahead_adder_32bit adder(.A(s5[2*i]), .B(s5[2*i+1]), .Sum(s6[i]));
        end
    endgenerate

    wire [31:0] s7 [0:1];
    generate
        for (i = 0; i < 2; i = i + 1) begin: s7_add
            carry_lookahead_adder_32bit adder(.A(s6[2*i]), .B(s6[2*i+1]), .Sum(s7[i]));
        end
    endgenerate

    wire [31:0] final_sum;
    carry_lookahead_adder_32bit final_adder(.A(s7[0]), .B(s7[1]), .Sum(final_sum));

    assign P = final_sum;

endmodule
