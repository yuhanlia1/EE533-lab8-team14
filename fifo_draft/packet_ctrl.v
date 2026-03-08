`timescale 1ns/1ps

module packet_ctrl(

input clk,
input rst,

input [7:0] ctrl_in,
input valid_in, //这一拍 ctrl_in / data_in 是不是一个真实的 packet word，或是空数据

output reg sop,
output reg eop

);

always @(posedge clk) begin
    if(rst) begin
        sop <= 0;
        eop <= 0;
    end
    else begin
        sop <= valid_in && (ctrl_in == 8'hff);
        eop <= valid_in && ctrl_in[7]; //判断packet结尾
    end
end

endmodule