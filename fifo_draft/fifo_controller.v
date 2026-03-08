`timescale 1ns/1ps

module fifo_controller #(
parameter ADDR_WIDTH = 9
)(

input clk,
input rst,

input write_en,
input packet_end, //packet到末尾

input cpu_done,

output reg fifo_full,
output reg packet_ready,

output reg [ADDR_WIDTH-1:0] head,
output reg [ADDR_WIDTH-1:0] tail
);

reg [1:0] state;

localparam IDLE      = 2'd0;
localparam RECEIVE   = 2'd1;
localparam WAIT_CPU  = 2'd2;
localparam SEND      = 2'd3;

always @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        head <= 0;
        tail <= 0;
        fifo_full <= 0;
        packet_ready <= 0;
    end
    else begin
		$display("STATE=%d head=%d tail=%d packet_ready=%d",
			state, head, tail, packet_ready);
        case(state)

        IDLE: begin //FIFO空闲，等待新 packet
            if(write_en) //FIFO写使能
                state <= RECEIVE;
        end

        RECEIVE: begin

			if(write_en) begin
				tail <= tail + 1;

				if(packet_end) begin
					fifo_full <= 1;
					packet_ready <= 1;
					state <= WAIT_CPU;
				end
			end
		end

        WAIT_CPU: begin //等待CPU处理
            if(cpu_done) begin //CPU处理完毕
                fifo_full <= 0;
                packet_ready <= 0;
                state <= SEND;
            end
        end

        SEND: begin //发送数据（读）
			if(head != tail)
				head <= head + 1;
			else
				state <= IDLE;
			end

        endcase
    end
end

endmodule