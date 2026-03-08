`timescale 1ns/1ps

module tb_convertible_fifo;

reg clk;
reg rst;

reg [63:0] in_data;
reg [7:0]  in_ctrl;
reg        in_wr;

wire       in_rdy;

wire [63:0] out_data;
wire [7:0]  out_ctrl;
wire        out_wr;

reg out_rdy;

reg cpu_mode;
reg [8:0] cpu_addr;
reg [71:0] cpu_wdata;
reg cpu_we;
wire [71:0] cpu_rdata;

reg cpu_done;

wire packet_ready;

convertible_fifo dut(

.clk(clk),
.rst(rst),

.in_data(in_data),
.in_ctrl(in_ctrl),
.in_wr(in_wr),

.in_rdy(in_rdy),

.out_data(out_data),
.out_ctrl(out_ctrl),
.out_wr(out_wr),

.out_rdy(out_rdy),

.cpu_mode(cpu_mode),
.cpu_addr(cpu_addr),
.cpu_wdata(cpu_wdata),
.cpu_we(cpu_we),
.cpu_rdata(cpu_rdata),

.cpu_done(cpu_done),

.packet_ready(packet_ready)

);

initial clk = 0;
always #5 clk = ~clk;

always @(posedge clk)
begin
    if(out_wr)
        $display("OUT  ctrl=%h data=%h",out_ctrl,out_data);
end

initial begin

rst = 1;
in_wr = 0;
out_rdy = 1;

cpu_mode = 0;
cpu_we = 0;
cpu_done = 0;

#30
rst = 0;

$display("----- SEND PACKET -----");

send_word(64'h1111111111111111,8'hff);
send_word(64'h2222222222222222,8'h00);
send_word(64'h3333333333333333,8'h00);
send_word(64'h4444444444444444,8'h80);

#50

$display("packet_ready = %b",packet_ready);

#20

$display("----- CPU READ PACKET -----");

cpu_mode = 1;

cpu_addr = dut.ctrl.head;
#10
$display("CPU READ %h",cpu_rdata);

cpu_addr = dut.ctrl.head + 1;
#10
$display("CPU READ %h",cpu_rdata);

cpu_addr = dut.ctrl.head + 2;
#10
$display("CPU READ %h",cpu_rdata);

cpu_addr = dut.ctrl.head + 3;
#10
$display("CPU READ %h",cpu_rdata);

cpu_mode = 0;

#20

$display("----- CPU DONE -----");

cpu_done = 1;
#10
cpu_done = 0;

#200

$finish;

end

task send_word;
input [63:0] data;
input [7:0] ctrl;
begin

in_data = data;
in_ctrl = ctrl;
in_wr   = 1;

@(posedge clk);

$display("WRITE ctrl=%h data=%h",ctrl,data);

in_wr = 0;

@(posedge clk);

end
endtask

endmodule