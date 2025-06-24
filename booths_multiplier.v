`timescale 1ns / 1ps

module booth_multiplier (
    input clk,
    input rst,
    input signed [15:0] multiplicand,
    input signed [15:0] multiplier,
    output reg signed [31:0] result
);
    reg signed [33:0] product;         // 17-bit accumulator + 16-bit multiplier + 1 bit
    reg signed [16:0] M;               // Sign-extended multiplicand
    reg [3:0] cycle;                   // 8 Booth cycles

    reg signed [33:0] temp_product;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            product <= 34'd0;
            M <= 17'd0;
            cycle <= 4'd0;
            result <= 32'sd0;
        end else begin
            if (cycle == 0) begin
                // Initialization
                M <= {multiplicand[15], multiplicand};     // Sign extend multiplicand
                product <= {17'd0, multiplier, 1'b0};      // Append 0 at LSB
                cycle <= 4'd8;
            end else begin
                // Use blocking assignments to avoid race conditions
                temp_product = product;

                // Booth encoding on lowest 3 bits
                case (product[2:0])
                    3'b000, 3'b111: ; // No operation
                    3'b001, 3'b010: temp_product[33:17] = temp_product[33:17] + M;              // +M
                    3'b011:         temp_product[33:17] = temp_product[33:17] + (M <<< 1);      // +2M
                    3'b100:         temp_product[33:17] = temp_product[33:17] - (M <<< 1);      // -2M
                    3'b101, 3'b110: temp_product[33:17] = temp_product[33:17] - M;              // -M
                endcase

                // Arithmetic right shift by 2
                product <= $signed(temp_product) >>> 2;

                cycle <= cycle - 1;

               if (product[32] == 1'b0) result <= product[32:1] >>> 2;
	           	else result <= $signed(product[32:1]) >>> 2 ;
            end
        end
    end
endmodule	
