`timescale 1ns/10ps
module hw3(
	input clk,
	input rst_in_n,
	input sfr_wr,
	input sfr_rd,
	input [7:0]sfr_data_out,
	input [7:0]sfr_addr,
	output reg[7:0]sfr_data_in,
	
	inout i2c_sda,
	output i2c_scl
	);
reg [9:0]freq = 9'd0;
reg sda_inorout = 1'd1; // 1'd1 for sda(out) , 1'd0 for sda(in).
reg sda = 1'b1;
reg scl = 1'b1;
wire p_sda;
wire n_sda;

reg [3:0]count = 4'd0;
reg M_start_stop = 1'b0;
reg start_bit = 1'b0;
reg [7:0]data_sending;
reg data_flag = 1'b0;

assign i2c_sda = sda_inorout? sda:1'dz;
assign i2c_scl = scl;

edge_detect write1(.clk(clk),.rst_n(reset_n),.data_in(sda),.pos_edge(p_sda),.neg_edge(n_sda)); 

always@(posedge clk or negedge rst_in_n)
begin
	if(!rst_in_n)
	begin
		freq <= 1'd0;
		scl <= 1'b1;
	end
	else if(freq == 9'd100)
	begin
		freq <= 1'd0;
		if(M_start_stop)
		begin
			scl = ~scl;
		end
	end
	else
		freq <= freq + 1'd1;
end
always@(posedge clk or negedge rst_in_n)
begin
	if(!rst_in_n)
	begin
		data_sending = 8'h00;
		sda = 1'b1;
		sda_inorout = 1'b1;
		M_start_stop = 1'b0;
		sda_inorout = 1'b1;
		start_bit = 1'b0;
		count = 1'd0;
		data_flag = 1'b0;
	end
	else
	begin
		if(sfr_addr == 8'h9c)
		begin
			data_sending = sfr_data_out;
			sfr_data_in = 8'h00;
		end
		else if(sfr_addr == 8'h9a)
		begin
			sda = 1'b0;
			start_bit = 1'b1;
		end
		else if(sfr_addr == 8'h9b)
		begin
		//怪怪的
			sfr_data_in = 8'h01;
		end
		if(sda == 1'b0 && start_bit == 1'b1)
		begin
			M_start_stop = 1'b1;
			start_bit = 1'b0;
		end
		if(M_start_stop)
		begin
			if(scl)
			begin
				case(count)
					4'd0:
					begin
						if(data_flag == 1'b1)
						begin	
							sda = data_sending[7];
							count = count + 1;
							data_flag = 1'b0;
						end
					end
					4'd1:
					begin
						if(data_flag == 1'b1)
						begin
							sda = data_sending[6];
							count = count + 1;
							data_flag = 1'b0;
						end
					end
					4'd2:
					begin
						if(data_flag == 1'b1)
						begin
							sda = data_sending[5];
							count = count + 1;
							data_flag = 1'b0;
						end
					end
					4'd3:
					begin
						if(data_flag == 1'b1)
						begin
							sda = data_sending[4];
							count = count + 1;
							data_flag = 1'b0;
						end
					end	
					4'd4:
					begin
						if(data_flag == 1'b1)
						begin
							sda = data_sending[3];
							count = count + 1;
							data_flag = 1'b0;
						end
					end
					4'd5:
					begin
						if(data_flag == 1'b1)
						begin
							sda = data_sending[2];
							count = count + 1;
							data_flag = 1'b0;
						end
					end
					4'd6:
					begin
						if(data_flag == 1'b1)
						begin
							sda = data_sending[1];
							count = count + 1;
							data_flag = 1'b0;
						end
					end
					4'd7:
					begin
						if(data_flag == 1'b1)
						begin
							sda = data_sending[0];
							count = count + 1;
							data_flag = 1'b0;
							sda_inorout = 1'b0;
						end
					end
				endcase
			end
		end
	end
end
endmodule 