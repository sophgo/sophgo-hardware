module switch_reset_control
(
clock,
reset,
int_1ms_en,
switch_sys_rst,
switch_prst,
pg_vdd_1v8,
en_pcie_sw_0v8_a,
en_pcie_sw_0v8_b,
pg_pcie_sw_0v8_a,
pg_pcie_sw_0v8_b
);


input wire clock;
input wire reset;

input wire int_1ms_en;

output reg switch_sys_rst;
output reg switch_prst;

output wire en_pcie_sw_0v8_a;
output wire en_pcie_sw_0v8_b;

//input wire pg_vdd_1v8;
input wire pg_pcie_sw_0v8_a;
input wire pg_pcie_sw_0v8_b;
input wire pg_vdd_1v8;

wire switch_pg;

assign switch_pg = pg_pcie_sw_0v8_a ;//& pg_pcie_sw_0v8_b ;

reg[7:0] switch_rst_cnt;

////////////////////////////////////////////////
//                                            //
//          三段式状态机检测产生复位信�     //
//                                            //
////////////////////////////////////////////////
reg[2:0] next_state;
reg[2:0] current_state;

localparam idle               = 3'b000,
		   pcie_0v8_on        = 3'b001,
		   switch_reset_low   = 3'b010, //单板上电过程
		   switch_reset_high  = 3'b011,
		   switch_prst_high   = 3'b100;
           

always@(posedge clock or negedge reset)
	begin
		if(!reset)
			begin
				current_state<=idle;
			end
		else
			begin
				current_state<=next_state;
			end
	end


reg[8:0] switch_0v8_cnt;

reg en_pcie_sw_0v8;

//第二段：组合逻辑，用于判断在输入信号作用下，next_state如何转换
always@(*)
	begin
		case(current_state)
			idle:
				begin
					if((pg_vdd_1v8==1'b1))
						next_state<=pcie_0v8_on;
					else
						next_state<=idle;
				end
			
			pcie_0v8_on:
				begin
					if(switch_0v8_cnt==9'd100)
						next_state<=switch_reset_low;
					else
						next_state<=pcie_0v8_on;
				
				end

			
			switch_reset_low:
				begin
					if(switch_rst_cnt==8'd120)
						next_state<=switch_reset_high;
					else
						next_state<=switch_reset_low;
				end
		
			switch_reset_high:
				begin
					if(switch_pg==1'b0)
						next_state <= idle;
					else
						if(switch_rst_cnt ==9'd400)
							next_state <= switch_prst_high;
						else
							next_state <= switch_reset_high;
				end

			switch_prst_high:
				begin
					if(switch_pg==1'b0)
						next_state <= idle;
					else
						next_state <= switch_prst_high;
					
				end
			

		endcase
	end

//第三�时序逻辑，用于产生每个state的输出信�

always@(posedge clock or negedge reset)
	begin
		if(!reset)
			begin
				switch_rst_cnt<=8'd0;
				switch_sys_rst<=1'b0;
				switch_prst<=1'b0;
				en_pcie_sw_0v8<=1'b0;
				switch_0v8_cnt<=9'd0;				
			end
		else
			begin
				case(current_state)
					idle:
						begin
							switch_sys_rst<=1'b0;
							switch_prst <= 1'b0;
							en_pcie_sw_0v8<=1'b0;
							switch_rst_cnt<=8'd0;
							switch_0v8_cnt<=9'd0;
						end
					
					pcie_0v8_on:
						begin
							switch_sys_rst<=1'b0;
							switch_prst <= 1'b0;
							switch_rst_cnt<=8'd0;
							if(switch_0v8_cnt==9'd100)
								begin
									en_pcie_sw_0v8<=1'b1;
									switch_0v8_cnt<=9'd0;
								end
							else
								begin
									if(int_1ms_en)
										begin
											switch_0v8_cnt<=switch_0v8_cnt + 1'b1;
											en_pcie_sw_0v8<=1'b0;
										end
								end
						end					
					
					
					
					switch_reset_low:
						begin
							switch_sys_rst<=1'b0;
							switch_prst <= 1'b0;
							if(int_1ms_en)
								begin
									switch_rst_cnt<=switch_rst_cnt + 1'b1;
								end
						end
					
					switch_reset_high:
						begin
							switch_sys_rst<=1'b1;
							switch_prst <= 1'b0;
							switch_rst_cnt<=8'b00;
							if(int_1ms_en)
								begin
									switch_rst_cnt<=switch_rst_cnt + 1'b1;
								end
						end	

					switch_prst_high:
						begin
							switch_prst<=1'b1;
							switch_rst_cnt<=9'b00;

						end			
				endcase
			end
	end

assign en_pcie_sw_0v8_a = pg_vdd_1v8;//en_pcie_sw_0v8;//en_vdd_1v8;
assign en_pcie_sw_0v8_b = pg_vdd_1v8;//en_pcie_sw_0v8;


endmodule


