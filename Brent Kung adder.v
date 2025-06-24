module BK (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] sum
);
    wire [31:0] g, p, c;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            assign g[i] = a[i] & b[i];
            assign p[i] = a[i] ^ b[i];
        end
    endgenerate

    assign c[0] = 1'b0;
    generate
        for (i = 1; i < 32; i = i + 1) begin
            assign c[i] = g[i-1] | (p[i-1] & c[i-1]);
        end
    endgenerate

    assign sum = p ^ c;
endmodule
