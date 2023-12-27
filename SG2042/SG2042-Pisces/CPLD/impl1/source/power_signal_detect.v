
module power_signal_detect
(
input wire clock,
input wire int_1ms_en,
input wire reset,

input wire pwr_btn,//本地按键处理
input wire rst_btn,

input wire bmc_power_out,//bmc 输出给CPLD的电源控制信反
input wire bmc_reset_out,

input wire post_complete,
input wire host_reboot,

//电源模块的控制信反
output reg is_pwr_on_off,
output reg is_pwr_force_off,

output wire is_normal_reboot,
output wire is_host_reboot,
output wire is_host_power_off
);

wire rst_ext;
wire rst_ext_in;

assign rst_ext_in = bmc_reset_out & rst_btn;

////////////////////////////////////////////////
//                                            //
//    复位检测，输出电源控制信号              //
//                                            //
////////////////////////////////////////////////
debounce_button_FSM rst_btn_dbn
(
.clock(clock),
.reset(reset),
.int_1ms_en(int_1ms_en),
.key(rst_ext_in),
.key_out(rst_ext),
.key_pulse()
);

assign is_normal_reboot = rst_ext;

assign is_host_power_off = !post_complete;

assign is_host_reboot = !host_reboot;


reg[2:0] current_state;
reg[2:0] next_state;

localparam	idle 				= 3'b000,
			debounce 			= 3'b001,
			low_time_count 		= 3'b010,
			normal_sig_generate = 3'b011,
			force_sig_generate  = 3'b100,
			bmc_steady			= 3'b101;

localparam  force_15s = 16'd10000,
			nomral_300ms = 16'd100;

reg[15:0] low_time_cnt;
reg[3:0] normal_sig_cnt;
reg[3:0] force_sig_cnt;
reg[15:0] debounce_cnt;

wire pwr_btn_pressed;
assign pwr_btn_pressed = pwr_btn & bmc_power_out;

wire pos_edge;
wire neg_edge;

reg sig_r0,sig_r1;//状态寄存器
always @(posedge clock)
begin
      if(!reset)
	    begin
		   sig_r0 <= 1'b0;
		   sig_r1 <= 1'b0;
		end
	  else
	    begin
		   sig_r0 <= pwr_btn;
		   sig_r1 <= sig_r0;
		end
end
 
assign pos_edge = ~sig_r1 & sig_r0;
assign neg_edge = sig_r1 & ~sig_r0;


always@(posedge clock or negedge reset )
begin
	if(!reset)
		current_state <= idle;
	else
		current_state <= next_state;
end

always@(*)
begin
	case(current_state)
		idle:
			begin
				if(pos_edge==1'b1)
					begin
						next_state=debounce;
					end
				else if(pwr_btn_pressed==1'b1)
					begin
						next_state=bmc_steady;
					end
				else
					begin
						next_state=idle;
					end
			end
		
		bmc_steady:
			begin
				if(pwr_btn_pressed==1'b0)
					begin
						next_state = low_time_count;
					end
				else
					begin
						next_state = bmc_steady;
					end
			end

		debounce:
			begin
				if((pwr_btn==1'b1)&&(debounce_cnt>nomral_300ms))
					begin
						next_state=normal_sig_generate;
					end
					
				else if((pwr_btn==1'b0)&&(debounce_cnt>force_15s))
					begin
						next_state=force_sig_generate;	
					end
					
				else if ((pwr_btn==1'b1)&&(debounce_cnt<nomral_300ms))
					begin
						next_state=idle;
					end
				else
					begin
						next_state=debounce;
					end
			end
			
		low_time_count:
			begin
				if((pwr_btn_pressed==1'b1)&&(low_time_cnt>nomral_300ms))
					begin
						next_state=normal_sig_generate;
					end
					
				else if((pwr_btn_pressed==1'b0)&&(low_time_cnt>force_15s))
					begin
						next_state=force_sig_generate;	
					end
					
				else if ((pwr_btn_pressed==1'b1)&&(low_time_cnt<nomral_300ms))
					begin
						next_state=idle;
					end
				else
					begin
						next_state=low_time_count;
					end
			end
	
		normal_sig_generate:
			begin
				if(normal_sig_cnt==4'd5)
					begin
						next_state=idle;
					end
				else
					next_state=normal_sig_generate;
			end

		force_sig_generate:
			begin
				if((force_sig_cnt==4'd5)&&(pwr_btn_pressed==1'b1))
					next_state=idle;
				else
					next_state=force_sig_generate;
			end
			
	endcase
end



always@(posedge clock or negedge reset)
begin
	if(!reset)
		begin
			is_pwr_on_off<=1'b1;
			is_pwr_force_off<=1'b1;
			low_time_cnt<=16'd0;
			normal_sig_cnt<=4'd0;
			force_sig_cnt<=4'd0;
			debounce_cnt<=16'd0;
		end
	else
		begin
			case(current_state)
				idle:
					begin
						is_pwr_on_off<=1'b1;
						is_pwr_force_off<=1'b1;
						debounce_cnt<=16'd0;
						low_time_cnt<=16'd0;
						normal_sig_cnt<=4'd0;
						force_sig_cnt<=4'd0;	
					end

				bmc_steady:
					begin
						is_pwr_on_off<=1'b1;
						is_pwr_force_off<=1'b1;
						debounce_cnt<=16'd0;
						low_time_cnt<=16'd0;
						normal_sig_cnt<=4'd0;
						force_sig_cnt<=4'd0;	
					end
			
				debounce:
					begin
						if(pwr_btn==1'b0)
							begin
								if(int_1ms_en)
									begin
										debounce_cnt<=debounce_cnt+1'b1;
									end
								else
									begin
										debounce_cnt<=debounce_cnt;
									end
							end
						else
							begin
								debounce_cnt<=debounce_cnt;
							end
					end
					
				low_time_count:
					begin
						if(pwr_btn_pressed==1'b0)
							begin
								if(int_1ms_en)
									begin
										low_time_cnt<=low_time_cnt+1'b1;
									end
								else
									begin
										low_time_cnt<=low_time_cnt;
									end
							end
						else
							begin
								low_time_cnt<=low_time_cnt;
							end
					end
			
				normal_sig_generate:
					begin
						if(normal_sig_cnt==4'd5)
							begin
								is_pwr_on_off<=1'b1;								
							end
						else if(int_1ms_en)
							begin
								is_pwr_on_off<=1'b0;
								normal_sig_cnt<=normal_sig_cnt+1'b1;
							end
					
					end
			
				force_sig_generate:
					begin
						if(force_sig_cnt==4'd5)
							begin
								is_pwr_force_off<=1'b1;								
							end
						else if(int_1ms_en)
							begin
								is_pwr_force_off<=1'b0;
								force_sig_cnt<=force_sig_cnt+1'b1;
							end
					
					end


			
			endcase
		end
end

endmodule
