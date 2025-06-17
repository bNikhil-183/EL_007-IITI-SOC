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


module booths_multiplier(
input[3:0] multiplicand,
input[3:0] multiplier,   
input clk,
output reg[7:0]result
);
reg[4:0] A=0; //ACCUMULAOR
reg[3:0] Q=0; //MULTIPLICAND
reg Q_1=0;
reg[3:0] M=0;
reg[2:0] count;
reg[7:0] Y;
always @(posedge clk) 
begin
if (count==0) begin
M <= multiplicand;
Q <= multiplier;
count <= 4;
A <= 0;
Q_1 <= 0;
end
else begin
 case ({Q[0], Q_1})
                2'b01: A <= A + M;
                2'b10: A <= A - M;
                default: A <= A;
            endcase
    {A, Q, Q_1} <= {A[4], A, Q, Q_1} >>> 1;
            count <= count - 1;

            if (count == 1) 
                result <= {A[3:0], Q};
          end
    end      
endmodule













