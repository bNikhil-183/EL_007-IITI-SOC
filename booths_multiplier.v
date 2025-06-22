`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.06.2025 00:28:17
// Design Name: 
// Module Name: booths_multiplier
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


module booths_multiplier_radix4 (
    input clk,
    input [15:0] multiplicand,
    input [15:0] multiplier,
    output reg [31:0] result
);

    reg signed [33:0] product = 0;         // Combined {A, Q, Q_-1} — total 33 bits
    reg signed [16:0] M = 0;               // Extended multiplicand
    reg [2:0] count = 0;

    reg [4:0] cycle = 0;                   // Radix-4: only 8 cycles

    always @(posedge clk) begin
        if (cycle == 0) begin
            M <= {multiplicand[15], multiplicand};  // Sign-extend to 17 bits
            product <= {17'd0, multiplier, 1'b0};    // A = 0, Q = multiplier, Q_-1 = 0
            cycle <= 8;
        end else begin
            // Extract current 3 bits: {Q1, Q0, Q_-1}
            case (product[2:0])
                3'b000, 3'b111: ;                            // 0 × M (do nothing)
                3'b001, 3'b010: product[33:17] <= product[33:17] + M;   // +1 × M
                3'b011: product[33:17] <= product[33:17] + (M << 1); // +2 × M
                3'b100: product[33:17] <= product[33:17] - (M << 1); // -2 × M
                3'b101, 3'b110: product[33:17] <= product[33:17] - M;   // -1 × M
            endcase

            // Arithmetic right shift by 2
            product <= $signed(product) >>> 2;

            cycle <= cycle - 1;

            if (cycle == 1) begin
                result <= product[32:1];  // Drop the LSB (Q_-1), result = A+Q
            end
        end
    end

endmodule
