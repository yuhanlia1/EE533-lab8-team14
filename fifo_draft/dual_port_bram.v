`timescale 1ns/1ps

module dual_port_bram #(
    parameter ADDR_WIDTH = 9,
    parameter DATA_WIDTH = 72
)(
    input clk,
	// portA写端口
    input [ADDR_WIDTH-1:0] addr_a, // 地址
    input [DATA_WIDTH-1:0] din_a, // 写入的数据
    input we_a, //写使能
    output reg [DATA_WIDTH-1:0] dout_a, //读出的数据
	// portB读端口
    input [ADDR_WIDTH-1:0] addr_b,
    input [DATA_WIDTH-1:0] din_b,
    input we_b,
    output reg [DATA_WIDTH-1:0] dout_b
);

reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

integer i;
initial begin
    for(i=0;i<(1<<ADDR_WIDTH);i=i+1)
        mem[i] = 0;
end

always @(posedge clk) begin
    if(we_a)
        mem[addr_a] <= din_a;
    dout_a <= mem[addr_a]; // 读永远发生
end

always @(posedge clk) begin
    if(we_b)
        mem[addr_b] <= din_b;
    dout_b <= mem[addr_b];
end

endmodule