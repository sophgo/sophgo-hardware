module eeprom_i2c
(
input   clk,
input   rst_n,
input   int_1ms_en ,
input[9:0]   word_addr,
input[7:0]   data_write_in,    
output reg[7:0]  data_read_out,
input    	 is_rw ,
input    start_sig,

input    scl_in,
input    sda_in,
output    scl_out,
output    sda_out,

output    scl_out_en,
output    sda_out_en
);

wire 		rd_data_vld;
wire[7:0]   rd_data ;
wire     i2c_busy;
reg      i2c_busy_1d ;
reg      i2c_rw ;
reg       i2c_start ;
reg       i2c_wait  ;

always@(posedge clk or negedge rst_n)
 begin
	if(!rst_n)
	begin
		data_read_out<=8'd0;
		i2c_busy_1d <= 1'b0;
		i2c_start <= 1'b0;
		i2c_rw <= 1'b1;
		i2c_wait <= 1'b0;
	end
	else
	begin
		i2c_busy_1d <= i2c_busy;
		
		if(rd_data_vld)
			data_read_out <= rd_data ;
		
		if(start_sig)
		begin
			if(~i2c_busy)
			begin
				i2c_start <= 1'b1;
				i2c_wait <= 1'b0;
				i2c_rw <= is_rw ;
			end
			else
			begin
				i2c_wait <= 1'b1;
				i2c_start <= 1'b0;
			end
		end
		else if(i2c_wait)
		begin
			if (i2c_busy_1d & (~i2c_busy))
			begin
				i2c_start <= 1'b1 ;
				i2c_wait <= 1'b0;
				i2c_rw <= is_rw ;
			end
			else
				i2c_start <= 1'b0;
		end
		else
			i2c_start <= 1'b0;
	end
end
  
 
i2c_master
#(
	.I2C_SPEED_DIV(10'd250)
) e2prom_i2c
(
	.clk(clk), 
	.rst_n(rst_n), 
	.device_addr({5'b10100,word_addr[9:8],i2c_rw}),         ///low bit  R/W bit
	.word_addr(word_addr[7:0]),
	.data_wr_in(data_write_in),
	.start(i2c_start),
	.start_again(1'b0),
	.scl_in(scl_in) ,    
	.sda_in(sda_in) ,
	.int_1ms_en(int_1ms_en),
	.rd_data (rd_data),
	.rd_data_vld(rd_data_vld),
	.scl_out(scl_out),
	.sda_out(sda_out),
	.scl_out_en(scl_out_en),
	.sda_out_en(sda_out_en),
	.i2c_busy(i2c_busy)
);


      
endmodule	  