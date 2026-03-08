`timescale 1ns/1ps

module convertible_fifo #(
parameter ADDR_WIDTH = 9,
parameter DATA_WIDTH = 72
)(

input clk,
input rst,
//写端口
input [63:0] in_data,
input [7:0]  in_ctrl,
//输入侧handshake（握手信号）
input in_wr, //进入FIFO的数据word是否有效
output in_rdy, //FIFO自身是否能接收新的数据

//读端口
output [63:0] out_data,
output [7:0]  out_ctrl,
output out_wr, //自身有效的数据word要发送
input out_rdy, //下游是否准备好接收数据

input cpu_mode, //FIFO 现在是网络模式还是CPU访问模式

input [ADDR_WIDTH-1:0] cpu_addr,
input [DATA_WIDTH-1:0] cpu_wdata,
input cpu_we,
output [DATA_WIDTH-1:0] cpu_rdata,

input cpu_done,  //cpu是否处理完毕

output packet_ready //packet准备好
);

wire sop;
wire eop;

packet_ctrl pkt_ctrl(

.clk(clk),
.rst(rst),

.ctrl_in(in_ctrl),
.valid_in(in_wr),

.sop(sop),
.eop(eop)
);

wire [ADDR_WIDTH-1:0] head; //读指针
wire [ADDR_WIDTH-1:0] tail; //写指针

wire fifo_full; //fifo满

fifo_controller #(
.ADDR_WIDTH(ADDR_WIDTH)
) ctrl (

.clk(clk),
.rst(rst),

.write_en(in_wr),
.packet_end(eop),

.cpu_done(cpu_done),

.fifo_full(fifo_full),
.packet_ready(packet_ready),

.head(head),
.tail(tail)
);

assign in_rdy = !fifo_full;

wire [ADDR_WIDTH-1:0] addr_a;
wire [ADDR_WIDTH-1:0] addr_b;

wire [DATA_WIDTH-1:0] din_a;
wire [DATA_WIDTH-1:0] dout_a;
wire [DATA_WIDTH-1:0] dout_b;

wire we_a;
// 模式切换
assign addr_a = cpu_mode ? cpu_addr : tail; //根据模式选择写地址
assign din_a  = cpu_mode ? cpu_wdata : {in_ctrl,in_data};
assign we_a   = cpu_mode ? cpu_we : in_wr;

assign addr_b = cpu_mode ? cpu_addr : head; //根据模式选择读地址

dual_port_bram #(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH(DATA_WIDTH)
) mem(

.clk(clk),

.addr_a(addr_a),
.din_a(din_a),
.we_a(we_a),
.dout_a(dout_a),

.addr_b(addr_b),
.din_b(0),
.we_b(0),
.dout_b(dout_b)

);

assign {out_ctrl,out_data} = dout_b;

assign out_wr = (!cpu_mode) && packet_ready && out_rdy;

assign cpu_rdata = dout_b;

endmodule