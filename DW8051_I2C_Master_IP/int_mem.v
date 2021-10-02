`timescale 1ns / 10ps
module  int_mem(        clk, 
                        addr,     
                        data_in,
                        data_out,
                        we1_n,    
                        we2_n,   
                        rd_n) ; 
input           clk;                        
input   [7:0]   addr;         
input   [7:0]   data_in;     
output  [7:0]   data_out;  
input           we1_n;
input           we2_n;
input           rd_n;   
reg     [7:0]   mem [255:0];
wire [7:0] mem_8 = mem[8];
wire [7:0] mem_9 = mem[9];

integer   i;
initial
  begin
  for (i=0;i<=255;i=i+1)
    mem[i] = 8'h00;
  end
wire #2 we2_n_dly = we2_n;
//assign data_out = rd_n ? 8'hxx : mem[addr];
assign data_out = mem[addr];


always @(clk )  
  begin
  if(!we1_n | !we2_n_dly)   
    mem[addr] <=#1 data_in;   
  end    
    
endmodule  
