`timescale 1ns / 10ps
module  sfr_mem(        clk, 
                        addr,     
                        data_in,
                        data_out,
                        wr_n,       
                        rd_n) ; 
input           clk;                        
input   [7:0]   addr;         
input   [7:0]   data_out;     
output  [7:0]   data_in;  
input           wr_n;
input           rd_n;   
reg     [7:0]   mem [255:0];
integer   i;
initial
  begin
  for (i=0;i<=255;i=i+1)
    mem[i] = 0;
  end
  
//assign data_out = rd_n ? 8'hxx : mem[addr];
assign data_out = mem[addr];

always @(clk)  
  begin
  if(!wr_n)     
    mem[addr] <=#1 data_in;       
  end  
  
endmodule      
