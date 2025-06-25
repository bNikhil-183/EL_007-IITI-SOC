`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2025 17:06:36
// Design Name: 
// Module Name: direct_multiplier
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

module full_adder (
    input a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module ripple_adder_16 (
    input [15:0] a, b,
    input cin,
    output [15:0] sum,
    output cout
);
    wire [31:0] c;

    full_adder fa0 (a[0], b[0], cin, sum[0], c[0]);
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : adders
            full_adder fa (a[i], b[i], c[i-1], sum[i], c[i]);
        end
    endgenerate
    assign cout = c[16];
endmodule

module ripple_adder_32 (
    input [31:0] a, b,
    input cin,
    output [31:0] sum,
    output cout
);
    wire [31:0] c;

    full_adder fa0 (a[0], b[0], cin, sum[0], c[0]);
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin : adders
            full_adder fa (a[i], b[i], c[i-1], sum[i], c[i]);
        end
    endgenerate
    assign cout = c[31];
endmodule

module twos_complement_16(
input [15:0]in,
output [15:0]out
);

wire[15:0] ones_complement;
wire dummy;
assign ones_complement= ~in;
ripple_adder_16 adder (ones_complement, 16'b1, 1'b0, out, dummy);
endmodule

module twos_complement_32(
input [31:0]in,
output [31:0]out
);

wire[31:0] ones_complement;
wire dummy;
assign ones_complement= ~in;
ripple_adder_32 adder (ones_complement, 32'b1, 1'b0, out, dummy);
endmodule

module multiplier_16bit(
  input  signed [15:0] a,
  input  signed [15:0] b,
  output signed [31:0] product
);
  wire [31:0] partials[15:0];
  wire a_neg = a[15];
  wire b_neg = b[15];
  wire [15:0] abs_a, abs_b;
  
  wire [15:0] temp_a, temp_b;
    twos_complement_16 tc_a(a, temp_a);
    twos_complement_16 tc_b(b, temp_b);
    assign abs_a = a_neg ? temp_a : a;
    assign abs_b = b_neg ? temp_b : b;
    
 wire [31:0] t[15:0];
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : pp_loop
            assign t[i] = abs_a & {16{abs_b[i]}};
            assign t[i] = t[i] << i;
        end
    endgenerate

    wire [31:0] sum1, sum2, sum3, sum4, sum5, sum6, sum7, sum8;
    wire [31:0] sum9, sum10, sum11, sum12, sum13, sum14, final_sum;
    wire dummy;

    ripple_adder_32 add1 (t[0], t[1], 0, sum1, dummy);
    ripple_adder_32 add2 (t[2], t[3], 0, sum2, dummy);
    ripple_adder_32 add3 (t[4], t[5], 0, sum3, dummy);
    ripple_adder_32 add4 (t[6], t[7], 0, sum4, dummy);
    ripple_adder_32 add5 (t[8], t[9], 0, sum5, dummy);
    ripple_adder_32 add6 (t[10], t[11], 0, sum6, dummy);
    ripple_adder_32 add7 (t[12], t[13], 0, sum7, dummy);
    ripple_adder_32 add8 (t[14], t[15], 0, sum8, dummy);

    ripple_adder_32 add9  (sum1, sum2, 0, sum9, dummy);
    ripple_adder_32 add10 (sum3, sum4, 0, sum10, dummy);
    ripple_adder_32 add11 (sum5, sum6, 0, sum11, dummy);
    ripple_adder_32 add12 (sum7, sum8, 0, sum12, dummy);

    ripple_adder_32 add13 (sum9, sum10, 0, sum13, dummy);
    ripple_adder_32 add14 (sum11, sum12, 0, sum14, dummy);

    ripple_adder_32 add15 (sum13, sum14, 0, final_sum, dummy);

   wire [31:0] temp_out;
    twos_complement_32 tc_out(final_sum, temp_out);
    assign product = a[15] ^ b[15] ? temp_out : final_sum;

endmodule

module direct_multiplier(
input signed[15:0] a1,b1,c1,d1,
input signed[15:0] a2,b2,c2,d2,
output [31:0] r1,r2,r3,r4
);
 wire[31:0] aa,bb,cc,dd;
 wire [31:0] ab, ba, ac, ca, ad, da;
 wire [31:0] bc, cb, bd, db, cd, dc;
 
//Multiplying the components using multplier
multiplier_16bit m1(a1,a2,aa);
multiplier_16bit m2(b1,b2,bb);
multiplier_16bit m3(c1,c2,cc);
multiplier_16bit m4(d1,d2,dd);

multiplier_16bit m5(a1,b2,ab);
multiplier_16bit m6(b1,a2,ba);
multiplier_16bit m7(c1,d2,cd);
multiplier_16bit m8(d1,c2,dc);

multiplier_16bit m9(a1,c2,ac);
multiplier_16bit m10(b1,d2,bd);
multiplier_16bit m11(c1,a2,ca);
multiplier_16bit m12(d1,b2,db);

multiplier_16bit m13(a1,d2,ad);
multiplier_16bit m14(b1,c2,bc);
multiplier_16bit m15(c1,b2,cb);
multiplier_16bit m16(d1,a2,da);

wire [31:0] t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11;
wire dummy;

wire[31:0] temp1,temp2,temp3,temp4,temp5;
//r1=a1a2-b1b2,-c1c2-d1d2
    twos_complement_32 neg_bb(bb, temp1);
    ripple_adder_32 sub1(aa,temp1,0,t1,dummy);

    twos_complement_32 neg_cc(cc, temp2);
    ripple_adder_32 sub2(t1,temp2,0,t2,dummy);

    twos_complement_32 neg_dd(dd,temp3);
    ripple_adder_32 sub3(t2, temp3,0,r1,dummy);

//r2=a1b2+b1a2+c1d2-d1c2
ripple_adder_32 add1(ab,ba,0,t3,dummy);
ripple_adder_32 add2(t3,cd,0,t4,dummy);
    twos_complement_32 neg_dc(dc,temp3);
    ripple_adder_32 sub4(t4,dc,0,r2,dummy);

//r3=a1c2-b1d2+c1a2+d1b2
  twos_complement_32 neg_bd(bd,temp4);
  ripple_adder_32 sub5(ac,bd,0,t5,dummy);
  ripple_adder_32 add3(t5,ca,0,t6,dummy);
ripple_adder_32 add4(t6,db,0,r3,dummy);

//r4=a1d2+b1c2-c1b2+d1a2
 ripple_adder_32 add5(ad,bc,0,t7,dummy);
 twos_complement_32 neg_cb(cb,temp5);
 ripple_adder_32 sub6(t7,cb,0,t8,dummy);
 ripple_adder_32 add6(t8,da,0,r4,dummy);
 
 endmodule
 
 
