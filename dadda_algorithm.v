`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2025 20:08:42
// Design Name: 
// Module Name: dadda_algorithm
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

module carry_lookahead_adder_32bit(
    input [31:0] A,
    input [31:0] B,
    output [31:0] Sum
);
    wire [31:0] carry;
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: rca_loop
            if (i == 0) begin
                full_adder fa(.a(A[i]), .b(B[i]), .cin(1'b0), .sum(Sum[i]), .carry(carry[i]));
            end else begin
                full_adder fa(.a(A[i]), .b(B[i]), .cin(carry[i-1]), .sum(Sum[i]), .carry(carry[i]));
            end
        end
    endgenerate
endmodule

module carry_lookahead_adder(
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

module dadda_algorithm(
    input [15:0] A,
    input [15:0] B,
    output [31:0] P
);
    wire [15:0] pp [15:0];
    wire [31:0] partial_sum;

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

      wire [31:0] stage1 [0:127];
    generate
        for (i = 0; i < 128; i = i + 1) begin: stage1_add
            carry_lookahead_adder rca(.A(sum[2*i]), .B(sum[2*i+1]), .Sum(stage1[i]));
        end
    endgenerate

    wire [31:0] stage2 [0:63];
    generate
        for (i = 0; i < 64; i = i + 1) begin: stage2_add
            carry_lookahead_adder rca(.A(stage1[2*i]), .B(stage1[2*i+1]), .Sum(stage2[i]));
        end
    endgenerate

    wire [31:0] stage3 [0:31];
    generate
        for (i = 0; i < 32; i = i + 1) begin: stage3_add
            carry_lookahead_adder rca(.A(stage2[2*i]), .B(stage2[2*i+1]), .Sum(stage3[i]));
        end
    endgenerate

    wire [31:0] stage4 [0:15];
    generate
        for (i = 0; i < 16; i = i + 1) begin: stage4_add
            carry_lookahead_adder rca(.A(stage3[2*i]), .B(stage3[2*i+1]), .Sum(stage4[i]));
        end
    endgenerate

    wire [31:0] stage5 [0:7];
    generate
        for (i = 0; i < 8; i = i + 1) begin: stage5_add
            carry_lookahead_adder rca(.A(stage4[2*i]), .B(stage4[2*i+1]), .Sum(stage5[i]));
        end
    endgenerate

    wire [31:0] stage6 [0:3];
    generate
        for (i = 0; i < 4; i = i + 1) begin: stage6_add
            carry_lookahead_adder rca(.A(stage5[2*i]), .B(stage5[2*i+1]), .Sum(stage6[i]));
        end
    endgenerate

    wire [31:0] stage7 [0:1];
    generate
        for (i = 0; i < 2; i = i + 1) begin: stage7_add
            carry_lookahead_adder rca(.A(stage6[2*i]), .B(stage6[2*i+1]), .Sum(stage7[i]));
        end
    endgenerate

    wire [31:0] final_sum;
    carry_lookahead_adder final_rca(.A(stage7[0]), .B(stage7[1]), .Sum(final_sum));

    assign P = final_sum;

endmodule
