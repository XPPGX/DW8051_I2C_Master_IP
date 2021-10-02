`timescale 1ns/10ps
module faker(
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
reg [9:0]freq = 10'd0;

reg sda = 1'b1;
reg scl = 1'b1;
reg sda_inorout = 1'b1;
reg dataflag = 1'b0; //dataflag = 1'b0 for 新的一個scl還沒傳過0x9c的data，dataflag = 1'b1 for已傳送過一個0x9c其中一個位元。
reg [4:0]count = 5'd0; //計數0x9c裡面的data傳到第幾個位元。 
reg start_condition = 1'b0;
reg sfflag = 1'b0;
reg [3:0]spflag = 3'd0;
reg ack_f = 1'b0;
reg [3:0]byte_count = 3'd0;
reg stop_condition = 1'b0;
reg oneortwo = 1'b0; // 1'b0 for one , 1'b1 for two.
reg stoping = 1'b0;
reg test1 = 1'b0;

reg M_start_stop = 1'b0; //Mission start = 1'b1 , Mission stop = 1'b0.
reg [7:0]data_sending = 8'h00;
reg slave_Re = 1'b0;

assign i2c_sda = sda_inorout?sda:1'dz;
assign i2c_scl = scl;

always@(posedge clk or negedge rst_in_n)
begin
	if(!rst_in_n)
	begin
		freq <= 0;
	end
	else if(freq == 10'd100)
	begin
		freq <= 0;
	end
	else
	begin
		freq <= freq + 1'd1;
	end
end

always@(posedge clk or negedge rst_in_n)
begin
	if(!rst_in_n)
	begin
		M_start_stop = 1'b0;	
		data_sending = 8'h00;
		slave_Re = 1'b0;
		sfr_data_in = 8'h00;
	end
	else
	begin
		case(sfr_addr)
			8'h9c:
			begin
				data_sending <= sfr_data_out;
			end
			8'h9a:
			begin
				M_start_stop <= 1'b1;
			end
			8'h9b:
			begin
				if(slave_Re == 1'b1)
				begin
					sfr_data_in = 8'h01;
				end
				else
				begin
					sfr_data_in = 8'h00;
				end
				slave_Re = 1'b0;
			end
		endcase
	end
end

always@(posedge clk or negedge rst_in_n)
begin
	if(!rst_in_n)
	begin
		sda = 1'b1;
		scl = 1'b1;
		sda_inorout = 1'b1;
		sfflag = 1'b0;
		spflag = 3'd0;
		dataflag = 1'b1;
		count = 4'd0;
		start_condition = 1'b0;
		ack_f = 1'b0;
		byte_count = 3'd0;
		stop_condition = 1'b0;
		stoping = 1'b0;
	end
	else
	begin
		if(M_start_stop && start_condition == 1'b0 && oneortwo == 1'b0)
		begin
			if(freq == 0 && sfflag == 1'b0)
			begin
				sda = 1'b0;
				sfflag = 1'b1;
			end
			else if(freq == 100 && sfflag == 1'b1)
			begin
				scl = 1'b0;
				sfflag = 1'b0;
				start_condition = 1'b1;
				freq <= 0;
			end
		end
		if(M_start_stop && start_condition == 1'b0 && oneortwo == 1'b1)
		begin
			sfflag = 1'b0;
			if(freq == 96 && sfflag == 1'b0)
			begin
				sda = 1'b0;
				sfflag = 1'b1;
			end
			else if(freq == 100 && sfflag == 1'b1)
			begin
				sfflag = 1'b0;
			end
			else if(freq == 100 && sfflag == 1'b0)
			begin
				scl = 1'b0;
				sfflag = 1'b1;
				start_condition = 1'b1;
				freq <= 0;
			end
		end
		if(start_condition == 1'b1)
		begin
			if(freq == 0 && sfflag == 1'b0)
			begin
				sfflag = 1'b1;
			end
			else if(freq == 100 && sfflag == 1'b1)
			begin
				sfflag = 1'b0;
				if(scl == 1'b0)
				begin
					scl = 1'b1;
				end
				else if(scl == 1'b1)
				begin
					scl = 1'b0;
				end
			end
			if(byte_count > 3'd0)
			begin
				if(scl == 1'b0 && freq == 0 && ack_f == 1'b0 && count == 1'b0)
				begin
					ack_f = 1'b1;
					sda_inorout = 1'b0;
					slave_Re = 1'b1;
				end
				if(scl == 1'b0 && freq == 73 && ack_f == 1'b1)
				begin
					count = 4'd0;
					sda_inorout = 1'b1;
					sda = data_sending[7-count];
					count = count + 1'd1;
					ack_f = 1'b0;
				end
			end
			if(scl == 1'b0 && freq == 50 && stop_condition == 1'b0)
			begin
				dataflag = 1'b1;
				case(count)
					4'd0:
					begin
						if(dataflag == 1'b1 && byte_count == 1'b0)
						begin
							sda_inorout = 1'b1;
							sda = data_sending[7-count];
							count = count + 1'd1;
							dataflag = 1'b0;
						end
					end
					4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7:
					begin
						if(dataflag == 1'b1)
						begin
							sda_inorout = 1'b1;
							sda = data_sending[7-count];
							count = count + 1'd1;
							dataflag = 1'b0;
						end
					end
					4'd8:
					begin
						if(dataflag == 1'b1)
						begin
							sda_inorout = 1'b1;
							sda = 1'b0;
							count = 4'd0;
							dataflag = 1'b0;
							byte_count = byte_count + 1'd1;
						end
						if(byte_count == 3'd4)
						begin
							byte_count = 3'd0;
							stop_condition = 1'b1;
							stoping = 1'b1;
						end
					end
				endcase
			end
		end
		if(stop_condition == 1'b1)
		begin
			if(scl == 1'b0 && freq == 0 && ack_f == 1'b0)
			begin
				ack_f = 1'b1;
				sda_inorout = 1'b0;
				slave_Re = 1'b1;
			end
			if(scl == 1'b0 && freq == 73 && ack_f == 1'b1)
			begin
				ack_f = 1'b0;
				sda_inorout = 1'b1;
				start_condition = 1'b0;
				M_start_stop <= 1'b0;
				stop_condition = 1'b0;
				slave_Re = 1'b0;
				oneortwo = 1'b1;
			end
		end
		if(start_condition == 1'b0 && stop_condition == 1'b0 && stoping == 1'b1)
		begin
			if(freq == 100 && spflag == 1'b0)
			begin
				spflag = 1'd1;
				scl = 1'b1;
				test1 = 1'b1;
			end
			else if(freq == 100 && spflag == 1'd1)
			begin
				spflag = 1'd0;
				sda = 1'b1;
				test1 = 1'b0;
				stoping = 1'b0;
			end
		end
	end
end

endmodule
