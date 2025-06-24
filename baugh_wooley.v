timescale 1ns / 1ps

module baugh_wooley (
    input  signed [15:0] a,
    input  signed [15:0] b,
    output signed [31:0] product
);
    wire [15:0] A = a;
    wire [15:0] B = b;
    wire [31:0] partial[15:0];

    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin: gen_partial
            for (j = 0; j < 16; j = j + 1) begin: gen_bit
                // Use XOR to determine if the result needs inversion
                wire negate = (i == 15) ^ (j == 15);  // true if exactly one is MSB
                assign partial[i][i+j] = negate ? ~(A[i] & B[j]) : (A[i] & B[j]);
            end

            // Zero padding
            for (j = 0; j < i; j = j + 1)
                assign partial[i][j] = 1'b0;
            for (j = i + 16; j < 32; j = j + 1)
                assign partial[i][j] = 1'b0;
        end
    endgenerate

    // Final accumulation with compensation
    reg signed [31:0] sum;
    integer k;
    always @(*) begin
        sum = 32'h00010001;  // Compensation bits
        for (k = 0; k < 16; k = k + 1)
            sum = sum + partial[k];
    end

    assign product = sum;
endmodule
