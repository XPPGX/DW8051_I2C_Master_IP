module  ext_mem(         addr,     
                        data_in,
                        data_out,
                        wr_n,       
                        rd_n) ; 
input   [15:0]   addr;         
input   [7:0]   data_in;     
output  [7:0]   data_out;  
input           wr_n;
input           rd_n;   
reg     [7:0]   mem [65535:0];

//assign data_out = rd_n ? 8'hxx : mem[addr];
assign data_out = mem[addr];

always @( wr_n )  
  begin
  if(!wr_n)     
    mem[addr] <= data_in;       
  end   
    
endmodule   
