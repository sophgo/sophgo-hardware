
module timer
(
	clock,
	reset,	
	int_1ms_en,
	int_100ms_en
);

input clock;
input reset;

output int_1ms_en;
output int_100ms_en;

wire clock;
wire reset;

reg[21:0]   int_100ms_cnt ;
reg[14:0]  int_1ms_cnt ;
reg        int_1ms_en ;
reg        int_100ms_en ;
reg[1:0]   rst_n_dly ;

always@(posedge clock or negedge reset)
 begin
  if(!reset)
	begin
		int_1ms_en   <= 1'b0;
		int_1ms_cnt   <= 0;
		rst_n_dly <= 2'b00;
	end
	else
	begin
		rst_n_dly <= { rst_n_dly[0],reset} ;
		if (rst_n_dly[1])
		begin
			if (int_1ms_cnt == 15'd24999)
			begin
				int_1ms_cnt <= 0;
				int_1ms_en <= 1'b1;
			end
			else
			begin
				int_1ms_cnt <= int_1ms_cnt + 1'b1;
				int_1ms_en <= 1'b0;	
			end
		end
	end
end

always@(posedge clock or negedge reset)
 begin
  if(!reset)
	begin
		int_100ms_en   <= 1'b0;
		int_100ms_cnt   <= 0;
	end
	else
	begin
		if (rst_n_dly[1])
		begin
		if (int_100ms_cnt == 22'd2499999)
			begin
				int_100ms_cnt <= 0;
				int_100ms_en <= 1'b1;
			end
		else
			begin
				int_100ms_cnt <= int_100ms_cnt + 1'b1;
				int_100ms_en <= 1'b0;
			end
		end
	end
end

endmodule



