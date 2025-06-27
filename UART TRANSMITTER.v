module uart_sender (
    input clk,
    input rst,
    input send,
    input [15:0] q0, q1, q2, q3,
    output tx,
    output reg busy
);
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 115200;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [2:0] state = 0;
    reg [7:0] tx_data;
    reg tx_start = 0;
    wire tx_busy;

    reg [7:0] bytes[0:7];
    reg [3:0] byte_index = 0;

    uart_byte_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .busy(tx_busy)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            busy <= 0;
        end else begin
            case (state)
                0: if (send) begin
                    bytes[0] <= q0[7:0]; bytes[1] <= q0[15:8];
                    bytes[2] <= q1[7:0]; bytes[3] <= q1[15:8];
                    bytes[4] <= q2[7:0]; bytes[5] <= q2[15:8];
                    bytes[6] <= q3[7:0]; bytes[7] <= q3[15:8];
                    byte_index <= 0;
                    state <= 1;
                    busy <= 1;
                end

                1: if (!tx_busy) begin
                    tx_data <= bytes[byte_index];
                    tx_start <= 1;
                    state <= 2;
                end

                2: begin
                    tx_start <= 0;
                    if (tx_busy)
                        state <= 3;
                end

                3: if (!tx_busy) begin
                    byte_index <= byte_index + 1;
                    if (byte_index == 7)
                        state <= 0;
                    else
                        state <= 1;
                end
            endcase
        end
    end
endmodule
