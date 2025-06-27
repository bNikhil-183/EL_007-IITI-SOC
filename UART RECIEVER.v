module uart_receiver (
    input clk,
    input rst,
    input rx,
    output reg [15:0] q0, q1, q2, q3,
    output reg valid
);
    // UART Parameters
    parameter CLK_FREQ = 50000000;  // 50MHz clock
    parameter BAUD_RATE = 115200;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [2:0] byte_count = 0;
    reg [7:0] data_buffer[0:7];
    wire rx_ready;
    wire [7:0] rx_data;

    // Instantiate UART Byte Receiver
    uart_byte_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_ready)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_count <= 0;
            valid <= 0;
        end else if (rx_ready) begin
            data_buffer[byte_count] <= rx_data;
            byte_count <= byte_count + 1;
            if (byte_count == 7) begin
                // Reconstruct 4 int16_t values
                q0 <= {data_buffer[1], data_buffer[0]};
                q1 <= {data_buffer[3], data_buffer[2]};
                q2 <= {data_buffer[5], data_buffer[4]};
                q3 <= {data_buffer[7], data_buffer[6]};
                valid <= 1;
                byte_count <= 0;
            end else begin
                valid <= 0;
            end
        end else begin
            valid <= 0;
        end
    end
endmodule
