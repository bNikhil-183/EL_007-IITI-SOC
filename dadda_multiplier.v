`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2025 15:15:32
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


// Half Adder
module half_adder(
    input a, b,
    output sum, carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule

// Full Adder
module full_adder(
    input a, b, cin,
    output sum, carry
);
    assign sum = a ^ b ^ cin;
    assign carry = (a & b) | (b & cin) | (a & cin);
endmodule

// Dadda Multiplier Top Module
module dadda_multiplier_16x16 (
    input [15:0] A,
    input [15:0] B,
    output [31:0] P
);
    // Partial product generation
    wire [15:0] pp [15:0];
    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin : pp_gen
            assign pp[i] = A & {16{B[i]}};
        end
    endgenerate

    // Create column-wise structure to hold partial products
    wire [255:0] column [0:30];
    generate
        for (i = 0; i < 31; i = i + 1) begin : column_init
            for (j = 0; j < 256; j = j + 1) begin : bit_init
                assign column[i][j] = 1'b0;
            end
        end
    endgenerate

    // Assign partial products to the corresponding columns
    generate
        for (i = 0; i < 16; i = i + 1) begin : row
            for (j = 0; j < 16; j = j + 1) begin : col
                assign column[i + j][i] = pp[i][j];
            end
        end
    endgenerate

    // Example reduction logic (not the full tree):
    wire s1_1, c1_1;
    half_adder HA1(column[1][0], column[1][1], s1_1, c1_1);

    wire s2_2, c2_2;
    full_adder FA1(column[2][0], column[2][1], column[2][2], s2_2, c2_2);

    wire s3_3a, c3_3a, s3_3b, c3_3b;
    full_adder FA2(column[3][0], column[3][1], column[3][2], s3_3a, c3_3a);
    half_adder HA2(s3_3a, column[3][3], s3_3b, c3_3b);

    // Placeholder for final rows (in practice, complete all reduction stages)
    wire [31:0] final_row1 = 32'b0; // Should hold the final row after Dadda tree reduction
    wire [31:0] final_row2 = 32'b0; // Second row to be added

    // Final addition using ripple-carry or any fast adder
    assign P = final_row1 + final_row2;

endmodule


