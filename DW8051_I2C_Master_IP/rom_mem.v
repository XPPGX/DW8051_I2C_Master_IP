module  rom_mem(         addr,                            
                        data_out,
                        cs_n,       
                        rd_n) ; 
input   [15:0]   addr;         
output  [7:0]   data_out;     
input           cs_n;
input           rd_n;   
reg     [7:0]   mem [0:65535];

initial    $readmemh("i2c.dat",mem);

//assign data_out = rd_n | cs_n ? 8'hxx : mem[addr];
assign data_out = mem[addr];


  
endmodule   
