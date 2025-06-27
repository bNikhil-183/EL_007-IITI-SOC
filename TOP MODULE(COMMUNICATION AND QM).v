module fpga_uart_qf (
    input clk,
    input rst,
    input rx,          // From Arduino
    output tx          // To Arduino
);
    wire signed [15:0] in0, in1, in2, in3;
    wire rx_valid;
    wire signed [15:0] dummy_b0 = 16'd1, dummy_b1 = 0, dummy_b2 = 0, dummy_b3 = 0; // Optional test B
    wire signed [31:0] out0, out1, out2, out3;
    reg send_uart;

    uart_receiver uart_rx (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .q0(in0),
        .q1(in1),
        .q2(in2),
        .q3(in3),
        .valid(rx_valid)
    );

    qf quaternion_block (
        .clk(clk),
        .rst(rst),
        .a0(in0), .a1(in1), .a2(in2), .a3(in3),
        .b0(dummy_b0), .b1(dummy_b1), .b2(dummy_b2), .b3(dummy_b3), // you can replace with any source
        .q0(out0), .q1(out1), .q2(out2), .q3(out3)
    );

    uart_sender uart_tx (
        .clk(clk),
        .rst(rst),
        .send(rx_valid),
        .q0(out0[15:0]),
        .q1(out1[15:0]),
        .q2(out2[15:0]),
        .q3(out3[15:0]),
        .tx(tx),
        .busy()
    );
endmodule
