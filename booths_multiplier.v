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


module booths_multiplier (
    input [15:0] multiplicand,
    input [15:0] multiplier,   
    input clk,
    output reg [31:0] result
);

    reg signed [16:0] A = 0;         // 1 bit extra for signed operation
    reg signed [15:0] Q = 0;         // Multiplier
    reg Q_1 = 0;                     // Extra bit for Booth's Algorithm
    reg signed [15:0] M = 0;         // Multiplicand
    reg [4:0] count = 0;             // Needs to count 16 cycles

    always @(posedge clk) begin
        if (count == 0) begin
            M <= multiplicand;
            Q <= multiplier;
            A <= 0;
            Q_1 <= 0;
            count <= 16;
        end
        else begin
            case ({Q[0], Q_1})
                2'b01: A <= A + M;   // A = A + M
                2'b10: A <= A - M;   // A = A - M
                default: A <= A;     // No operation
            endcase

            // Arithmetic right shift of {A, Q, Q_1}
            {A, Q, Q_1} <= {A[16], A, Q, Q_1} >>> 1;

            count <= count - 1;

            if (count == 1) begin
                result <= {A[15:0], Q};  // Final 32-bit result
            end
        end
    end

endmodule















