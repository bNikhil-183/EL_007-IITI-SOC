`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.06.2025 22:52:20
// Design Name: 
// Module Name: direct_multiplicator
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


module direct_multiplicator (
 input signed [15:0] a0, a1, a2, a3, 
  input signed [15:0] b0, b1, b2, b3, 
  output signed [31:0] c0, c1, c2, c3 
);

  assign c0 = a0*b0 - a1*b1 - a2*b2 - a3*b3;
  assign c1 = a0*b1 + a1*b0 + a2*b3 - a3*b2;
  assign c2 = a0*b2 - a1*b3 + a2*b0 + a3*b1;
  assign c3 = a0*b3 + a1*b2 - a2*b1 + a3*b0;

endmodule