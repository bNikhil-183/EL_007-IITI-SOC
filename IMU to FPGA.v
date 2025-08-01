`timescale 1ns / 1ps
`default_nettype none

module imu_to_quat_delta (
    input  wire clk,
    input  wire rst,
    input  wire signed [15:0] wx,
    input  wire signed [15:0] wy,
    input  wire signed [15:0] wz,
    input  wire [31:0] dt,
    output reg signed [15:0] dq0,
    output reg signed [15:0] dq1,
    output reg signed [15:0] dq2,
    output reg signed [15:0] dq3
);

    reg signed [31:0] wx_dt, wy_dt, wz_dt;
    localparam signed [15:0] Q15_ONE = 16'sd32767; // 1.0 in Q15

    always @(posedge clk) begin
        if (rst) begin
            dq0 <= 16'sd0;
            dq1 <= 16'sd0;
            dq2 <= 16'sd0;
            dq3 <= 16'sd0;
            wx_dt <= 32'sd0;
            wy_dt <= 32'sd0;
            wz_dt <= 32'sd0;
        end else begin
            // Multiply angular velocity by timestep
            wx_dt <= wx * dt;
            wy_dt <= wy * dt;
            wz_dt <= wz * dt;

            dq0 <= Q15_ONE;            // scalar approx 1.0
            // Adjusted shift from 17 to 14 to avoid too-small deltas
            dq1 <= wx_dt >>> 14;
            dq2 <= wy_dt >>> 14;
            dq3 <= wz_dt >>> 14;
        end
    end

endmodule

`default_nettype wire
