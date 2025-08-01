`timescale 1ns / 1ps

module algorithmic_multiplication_pipelined (
    input wire clk1,
    input wire clk2,
    input wire rst,
    input wire start,
    input signed [15:0] a0, a1, a2, a3,
    input signed [15:0] b0, b1, b2, b3,
    output signed [31:0] q0, q1, q2, q3,
    output done
);

    wire signed [31:0] m[0:13];
    reg [13:0] m_done_reg;
    wire [13:0] m_done;

    /////////////////////////////////
    // Stage 1: 14 Parallel Multiplies (Booth & Baugh-Wooley)
    /////////////////////////////////
    booth_multiplier_pipelined     M0 (.clk(clk1), .rst(rst), .multiplicand(a0), .multiplier(b0), .result(m[0]), .done(m_done[0]));
    baugh_wooley_pipelined         M1 (.clk(clk1), .rst(rst), .start(start), .a(a1), .b(b1), .product(m[1]), .done(m_done[1]));
    booth_multiplier_pipelined     M2 (.clk(clk1), .rst(rst), .multiplicand(a2), .multiplier(b2), .result(m[2]), .done(m_done[2]));
    baugh_wooley_pipelined         M3 (.clk(clk1), .rst(rst), .start(start), .a(a3), .b(b3), .product(m[3]), .done(m_done[3]));
    booth_multiplier_pipelined     M4 (.clk(clk1), .rst(rst), .multiplicand(a0), .multiplier(b1), .result(m[4]), .done(m_done[4]));
    baugh_wooley_pipelined         M5 (.clk(clk1), .rst(rst), .start(start), .a(a1), .b(b0), .product(m[5]), .done(m_done[5]));
    booth_multiplier_pipelined     M6 (.clk(clk1), .rst(rst), .multiplicand(a0), .multiplier(b2), .result(m[6]), .done(m_done[6]));
    baugh_wooley_pipelined         M7 (.clk(clk1), .rst(rst), .start(start), .a(a2), .b(b0), .product(m[7]), .done(m_done[7]));
    booth_multiplier_pipelined     M8 (.clk(clk1), .rst(rst), .multiplicand(a0), .multiplier(b3), .result(m[8]), .done(m_done[8]));
    baugh_wooley_pipelined         M9 (.clk(clk1), .rst(rst), .start(start), .a(a3), .b(b0), .product(m[9]), .done(m_done[9]));
    booth_multiplier_pipelined    M10 (.clk(clk1), .rst(rst), .multiplicand(a1), .multiplier(b2), .result(m[10]), .done(m_done[10]));
    baugh_wooley_pipelined        M11 (.clk(clk1), .rst(rst), .start(start), .a(a2), .b(b1), .product(m[11]), .done(m_done[11]));
    booth_multiplier_pipelined    M12 (.clk(clk1), .rst(rst), .multiplicand(a1), .multiplier(b3), .result(m[12]), .done(m_done[12]));
    baugh_wooley_pipelined        M13 (.clk(clk1), .rst(rst), .start(start), .a(a3), .b(b1), .product(m[13]), .done(m_done[13])); // Fixed: was a3*b2, now a3*b1

    // Latch done bits to detect completion
    always @(posedge clk1 or posedge rst) begin
        if (rst)
            m_done_reg <= 14'd0;
        else
            m_done_reg <= m_done_reg | m_done;  // Latches any high 'done' bits
    end

    assign done = (m_done_reg == 14'b11111111111111);
    /////////////////////////////////
    // Stage 2: 12 Add/Sub using CLA (Corrected Expressions)
    /////////////////////////////////
    wire signed [31:0] t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11;

    // q0 = a0*b0 - a1*b1 - a2*b2 - a3*b3
    cla32_pipelined SUB1 (.clk(clk2), .rst(rst), .a(m[0]), .b(-m[1]), .sum(t0));
    cla32_pipelined SUB2 (.clk(clk2), .rst(rst), .a(t0), .b(-m[2]), .sum(t1));
    cla32_pipelined SUB3 (.clk(clk2), .rst(rst), .a(t1), .b(-m[3]), .sum(q0));

    // q1 = a0*b1 + a1*b0 + a2*b3 - a3*b2
    cla32_pipelined ADD1 (.clk(clk2), .rst(rst), .a(m[4]), .b(m[5]), .sum(t2));
    cla32_pipelined ADD2 (.clk(clk2), .rst(rst), .a(t2), .b(m[12]), .sum(t3));
    cla32_pipelined SUB4 (.clk(clk2), .rst(rst), .a(t3), .b(m[13]), .sum(q1));

    // q2 = a0*b2 - a1*b3 + a2*b0 + a3*b1
    cla32_pipelined SUB5 (.clk(clk2), .rst(rst), .a(m[6]), .b(m[12]), .sum(t4));
    cla32_pipelined ADD3 (.clk(clk2), .rst(rst), .a(t4), .b(m[7]), .sum(t5));
    cla32_pipelined ADD4 (.clk(clk2), .rst(rst), .a(t5), .b(m[13]), .sum(q2));

    // q3 = a0*b3 + a1*b2 - a2*b1 + a3*b0
    cla32_pipelined ADD5 (.clk(clk2), .rst(rst), .a(m[8]), .b(m[10]), .sum(t6));
    cla32_pipelined SUB6 (.clk(clk2), .rst(rst), .a(t6), .b(m[11]), .sum(t7));
    cla32_pipelined ADD6 (.clk(clk2), .rst(rst), .a(t7), .b(m[9]), .sum(q3));

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Booth Multiplier Pipelined
//////////////////////////////////////////////////////////////////////////////////

module booth_multiplier_pipelined (
    input clk,
    input rst,
    input signed [15:0] multiplicand,
    input signed [15:0] multiplier,
    output reg signed [31:0] result,
    output reg done
);
    reg signed [33:0] A, S, P;
    reg [4:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A <= 0; S <= 0; P <= 0; count <= 0;
            result <= 0;
            done <= 0;
        end else begin
            if (count == 0) begin
                A <= {multiplicand, 17'd0};
                S <= {-multiplicand, 17'd0};
                P <= {17'd0, multiplier, 1'b0};
                count <= 8;
                done <= 0;
            end else if (count > 0) begin
                case (P[1:0])
                    2'b01: P <= P + A;
                    2'b10: P <= P + S;
                endcase
                P <= $signed(P) >>> 1;
                count <= count - 1;
                if (count == 1) begin
                    result <= P[32:1];
                    done <= 1;
                end else begin
                    done <= 0;
                end
            end
        end
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Baugh-Wooley Multiplier Pipelined
//////////////////////////////////////////////////////////////////////////////////

module baugh_wooley_pipelined (
    input wire clk,
    input wire rst,
    input wire start,
    input signed [15:0] a,
    input signed [15:0] b,
    output reg signed [31:0] product,
    output reg done
);
    reg [1:0] state;
    reg signed [15:0] a_reg, b_reg;
    reg signed [31:0] partial;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            product <= 0;
            done <= 0;
        end else begin
            case (state)
                0: if (start) begin
                    a_reg <= a;
                    b_reg <= b;
                    state <= 1;
                    done <= 0;
                end
                1: begin
                    partial <= a_reg * b_reg; // Replace with Baugh-Wooley logic for optimization
                    state <= 2;
                end
                2: begin
                    product <= partial;
                    done <= 1;
                    state <= 0;
                end
            endcase
        end
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
// CLA 32-bit Adder Pipelined
//////////////////////////////////////////////////////////////////////////////////

module cla32_pipelined (
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] sum
);
    reg [31:0] a_reg, b_reg;
    reg [31:0] carry, temp_sum;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 0;
            a_reg <= 0;
            b_reg <= 0;
            carry <= 0;
            temp_sum <= 0;
        end else begin
            a_reg <= a;
            b_reg <= b;
            {carry, temp_sum} <= a + b;
            sum <= temp_sum;
        end
    end
endmodule
