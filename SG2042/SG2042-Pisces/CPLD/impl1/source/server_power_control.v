
module server_power_control
(
input wire clock,
input wire reset,
input wire int_1ms_en,
input wire int_100ms_en,

input wire rst_btn,//本地复位按键
input wire pwr_btn,//本地按键处理

input wire bmc_power_out,//bmc 输出给CPLD的电源控制信�
input wire bmc_reset_out,//bmc 输出给CPLD的复位控制信�

output reg host_pwr_off, //cpld输出给Host，表示CPU要开始做下电操作
input wire post_complete,//host输出给CPLD，表示完成软件操作，需要开始下�
input wire host_reboot,

//psu control
input wire psu0_pwrok,
input wire psu1_pwrok,
output wire psu_ps_on_cpld,

//efuse
output wire en_vdd_12v,
input  wire ncp0_gok,
output wire en_12v_bp,
input  wire bp_ncp_gok,

//pg misc
output wire en_bp_5v,
output wire en_3v3_riser,

//cpu电源信号
output wire en_vddc_a,
output wire en_pcie_phy_a,
output wire en_vddq_a0,
output wire en_vddq_a1,
output wire en_vpp_a0,
output wire en_vpp_a1,
output wire en_vtt_a0,
output wire en_vtt_a1,
output wire en_ddr_phy_a,
output wire en_pcie_h_a,
output wire en_vqps18_a,
output wire pwr_button_a,

output wire en_vddc_b,
output wire en_pcie_phy_b,
output wire en_vddq_b0,
output wire en_vddq_b1,
output wire en_vpp_b0,
output wire en_vpp_b1,
output wire en_vtt_b0,
output wire en_vtt_b1,
output wire en_ddr_phy_b,
output wire en_pcie_h_b,
output wire en_vqps18_b,
output wire pwr_button_b,

output wire en_vdd_1v8,
output wire en_vdd_3v3,
output wire en_vdd_5v,

output wire cpua_rst_pwr,
output wire cpub_rst_pwr,//上下电过程中对CPU_SYS_RESET做操�

input wire cpua_pwrok,
input wire cpub_pwrok,
//input brd_pwrok;

//pcie switch信号
output wire en_pcie_sw_0v8_a,
output wire en_pcie_sw_0v8_b,
output wire switch_sys_rst,
output wire switch_prst,
input wire pg_pcie_sw_0v8_a,
input wire pg_pcie_sw_0v8_b,
input wire pg_vdd_1v8
);

////////////////////////////////////////////////
//                                            //
//    BMC和按键检测，输出电源控制信号         //
//                                            //
////////////////////////////////////////////////

//wire pwr_enable; //0:enable,1:hold

wire is_pwr_on_off;
wire is_pwr_force_off;

wire is_normal_reboot;
wire is_host_reboot;
wire is_host_power_off;

power_signal_detect power_signal_detect_inst
(
.clock(clock),
.int_1ms_en(int_1ms_en),
.reset(reset),

.pwr_btn(pwr_btn),//本地按键处理
.rst_btn(rst_btn),

.bmc_power_out(bmc_power_out),//bmc 输出给CPLD的电源控制信�
.bmc_reset_out(bmc_reset_out),
.post_complete(post_complete),
.host_reboot(host_reboot),

//电源模块的控制信�
.is_pwr_on_off(is_pwr_on_off),
.is_pwr_force_off(is_pwr_force_off),
.is_normal_reboot(is_normal_reboot),
.is_host_reboot(is_host_reboot),
.is_host_power_off(is_host_power_off)
);



////////////////////////////////////////////////
//                                            //
//    上电时序控制                           //
//                                            //
////////////////////////////////////////////////

wire brd_pwrok;
wire power_on_off;

assign power_on_off = is_pwr_on_off; 

////////////////////////////////////////////////
//                                            //
//    三段式状态控制上下电时序                //
//                                            //
////////////////////////////////////////////////

reg[3:0] next_state;
reg[3:0] current_state;

wire psu_pwrok;
wire efuse_pwrok;
reg efuse_done;
reg[8:0] psu_dly;
reg[8:0] efuse_dly;
reg[7:0] cpu_dly;
reg[15:0] wait_time_out_cnt;
reg wait_time_out;

reg psu_done;

assign psu_pwrok   = psu0_pwrok | psu1_pwrok;
assign efuse_pwrok = ncp0_gok & bp_ncp_gok;
assign brd_pwrok = cpua_pwrok & cpub_pwrok ;//& pg_pcie_sw_0v8_a & pg_pcie_sw_0v8_b;

localparam idle               = 4'b0000,
           pwr_state_detect   = 4'b0001,
		   psu_on             = 4'b0010,
		   efuse_on           = 4'b0011,
		   cpu_on             = 4'b0101,
		   power_steady       = 4'b0110,
		   wait_post_complete = 4'b0111,
		   cpu_off            = 4'b1000,
		   efuse_off          = 4'b1001,	
		   psu_off            = 4'b1010,
		   power_reboot       = 4'b1011;
		   		   
//第一段时序逻辑，用于描述当前状态和下一状态的转换
always@(posedge clock or negedge reset)
	begin
		if(!reset) //低电平复�
			begin
				current_state<=idle;
			end
		else
			begin
				current_state<=next_state;
			end
	end

//第二段组合逻辑，用于描述在输入信号的作用下状态的转换
reg cpu_off_done;

reg is_reboot;
reg[15:0] reboot_cnt;

always@(*)
	begin
		case(current_state)
			idle:
				begin
					if((power_on_off==1'b0))
						begin
							next_state=pwr_state_detect;
						end
					else
						begin
							next_state=idle;
						end
				end
		
			pwr_state_detect:
				begin
					if(brd_pwrok==1'b0)
						begin
							next_state = psu_on;
						end
					else
						begin
							next_state = cpu_off;
						end
				end
		
			psu_on:
				begin
					if(psu_done==1'b1)
						begin
							next_state = efuse_on;
						end
					else
						begin
							next_state = psu_on;
						end
				end
			
			efuse_on:
				begin
					if(efuse_done==1'b1)
						begin
							next_state = cpu_on;
						end
					else
						begin
							next_state = efuse_on;
						end
				end				
			
			cpu_on:
				begin
					if((cpua_pwrok==1'b1)||(cpub_pwrok==1'b1))
						begin
							next_state = power_steady;
						end
					else
						begin
							next_state = cpu_on;
						end
				end	

			power_steady:
				begin
					if(power_on_off==1'b0)
						begin
							next_state = wait_post_complete;
						end
						
					else if(is_normal_reboot==1'b0)
						begin
							next_state = wait_post_complete;	
						end
						
					else if(is_host_reboot==1'b0)
						begin
							next_state = cpu_off;	
						end						
						
					else if(is_pwr_force_off==1'b0)
						begin
							next_state = cpu_off;
						end
						
					else if(is_host_power_off==1'b0)	
						begin
							next_state = cpu_off;
						end					
					
					else
						begin
							next_state=power_steady;
						end						
				end
			
			wait_post_complete:
				begin
					if(post_complete==1'b1)
						begin
							next_state=cpu_off;
						end
					else if(wait_time_out ==1'b1)
						begin
							next_state=cpu_off;
						end	
					else if(is_pwr_force_off==1'b0)
						begin
							next_state = cpu_off;
						end	
					else
						next_state=wait_post_complete;
				end

						
			cpu_off:
				begin
					if(cpu_off_done==1'b1)
						begin
							next_state=efuse_off;
						end
					else
						begin
							next_state=cpu_off;
						end
				end

			efuse_off:
				begin
					if(efuse_done ==1'b1)
						begin
							next_state=psu_off;
						end
					else
						begin
							next_state=efuse_off;
						end
				end

			psu_off:
				begin
					if(psu_done ==1'b1)
						begin
							if(is_reboot==1'b0)
								next_state = power_reboot;
							else
								next_state = idle;
						end
					else
						begin
							next_state=psu_off;
						end
				end
				
			power_reboot:
				begin
					if(reboot_cnt==15'd100)
						next_state = psu_on;
					else
						next_state = power_reboot;
				end				
				
				
		endcase
			
	end

//第三段：产生每个状态的输出信号
reg psu_on_off;
reg cpu_pwr_on_off;
reg efuse_pwr_on_off;

always@(posedge clock or negedge reset)
	begin
		if(!reset)
			begin
				psu_on_off   <=1'b0;
				efuse_pwr_on_off <=1'b0;
				cpu_pwr_on_off   <=1'b0;
				cpu_off_done<=1'b0;
				cpu_dly<=8'h00;
				host_pwr_off<=1'b0;
				is_reboot<=1'b1;
				reboot_cnt<=15'd0;
				efuse_done<=1'b0;
				efuse_dly<=9'd0;
				psu_done<=1'b0;
				psu_dly<=9'd0;	
				wait_time_out_cnt<=16'd0;
				wait_time_out<=1'b0;
			end
		else
			begin
				case(current_state)
					idle:
						begin
							psu_on_off   <=1'b0;
							efuse_pwr_on_off <=1'b0;
							cpu_pwr_on_off   <=1'b0;
							cpu_off_done<=1'b0;
							host_pwr_off<=1'b0;
							is_reboot<=1'b1;
							reboot_cnt<=15'd0;
							efuse_done<=1'b0;
							efuse_dly<=9'd0;
							psu_done<=1'b0;
							psu_dly<=9'd0;	
							wait_time_out_cnt<=16'd0;
							wait_time_out<=1'b0;
						end
				
					psu_on:
						begin
							psu_on_off   <=1'b1;
							efuse_pwr_on_off <=1'b0;
							cpu_pwr_on_off   <=1'b0;
							
							if(psu_dly==9'd50)
								begin
									psu_dly<=9'd0;
									psu_done<=1'b1;
								end
							else if(int_1ms_en)
								begin
									psu_dly<=psu_dly+1'd1;
									psu_done<=1'b0;
								end	
						end

					efuse_on:
						begin
							psu_on_off   <=1'b1;
							efuse_pwr_on_off <=1'b1;
							cpu_pwr_on_off   <=1'b0;
							if(int_1ms_en)
								begin
									efuse_dly<=efuse_dly+1'd1;
								end
							
							if(efuse_dly==9'd300)
								begin
									if(efuse_pwrok==1'b1)
										begin
											efuse_done<=1'b1;
											efuse_dly<=9'd0;
										end
									else
										efuse_done<=1'b0;	
								end	
						end

					cpu_on:
						begin
							psu_on_off   <=1'b1;
							efuse_pwr_on_off <=1'b1;
							cpu_pwr_on_off   <=1'b1;						
						end
				
					power_steady:
						begin
							psu_on_off   <=1'b1;
							efuse_pwr_on_off <=1'b1;
							cpu_pwr_on_off   <=1'b1;
							if((is_normal_reboot==1'b0)||(is_host_reboot==1'b0))
								begin
									is_reboot<=1'b0;
								end
						end

					wait_post_complete:
						begin
							host_pwr_off<=1'b1;
							if(wait_time_out_cnt==16'd600)
								begin
									host_pwr_off<=1'b1;
									wait_time_out<=1'b1;
									wait_time_out_cnt<=16'd0;
								end
							else if(int_100ms_en)
								begin
									host_pwr_off<=1'b1;
									wait_time_out<=1'b0;
									wait_time_out_cnt <= wait_time_out_cnt + 8'd1;								
								end
						end

					cpu_off:
						begin
							if(cpu_dly==8'd50)
								begin
									psu_on_off       <= 1'b1;
									efuse_pwr_on_off <= 1'b1;
									cpu_pwr_on_off   <= 1'b0;
									cpu_off_done     <= 1'b1;
									efuse_done		 <=1'b0;
									wait_time_out<=1'b0;
									cpu_dly     <= 8'h00;
								end
							else if(int_1ms_en)
								begin
									psu_on_off       <= 1'b1;
									efuse_pwr_on_off <= 1'b1;
									cpu_pwr_on_off   <= 1'b0;
									cpu_off_done     <= 1'b0;
									wait_time_out<=1'b0;
									cpu_dly     <= cpu_dly+1'b1;
								end
						end

					efuse_off:
						begin							
							if(efuse_dly==8'd50)
								begin
									psu_on_off       <= 1'b1;
									efuse_pwr_on_off <= 1'b0;
									cpu_pwr_on_off   <= 1'b0;
									cpu_off_done     <= 1'b1;
									efuse_done<= 1'b1;
									psu_done<=1'b0;
									efuse_dly     <= 8'h00;
								end
							else if(int_1ms_en)
								begin
									psu_on_off       <= 1'b1;
									efuse_pwr_on_off <= 1'b0;
									cpu_pwr_on_off   <= 1'b0;
									cpu_off_done     <= 1'b1;
									efuse_dly     <= efuse_dly+1'b1;
								end	
						end

					psu_off:
						begin
							if(psu_dly==8'd50)
								begin
									psu_on_off       <= 1'b0;
									efuse_pwr_on_off <= 1'b0;
									cpu_pwr_on_off   <= 1'b0;
									cpu_off_done     <= 1'b1;
									psu_done<=1'b1;
									psu_dly     <= 8'h00;
								end
							else if(int_1ms_en)
								begin
									psu_on_off       <= 1'b0;
									efuse_pwr_on_off <= 1'b0;
									cpu_pwr_on_off   <= 1'b0;
									cpu_off_done     <= 1'b1;
									psu_done<=1'b0;
									psu_dly     <= psu_dly+1'b1;
								end
						end
						
					power_reboot:
						begin
							if((is_normal_reboot==1'b1)||(is_host_reboot==1'b1))
								begin
									if(reboot_cnt==15'd100)
										begin
											reboot_cnt<=15'd0;
											host_pwr_off<=1'b0;
											is_reboot<=1'b1;
											psu_done<=1'b0;
											efuse_done<= 1'b0;
										end
									else
										if(int_1ms_en==1'b1)
										begin
											reboot_cnt<=reboot_cnt+1'b1;
											host_pwr_off<=1'b0;
										end							
								end
							else
								begin
									reboot_cnt<=15'd0;
									host_pwr_off<=1'b1;
								end
					end		
						
				endcase
			end
	
	end
	
	
////////////////////////////////////////////////
//                                            //
//    每个模块的上电控制逻辑                  //
//                                            //
////////////////////////////////////////////////
//output wire psu_ps_on_cpld;

assign psu_ps_on_cpld = psu_on_off;

assign en_vdd_12v = efuse_pwr_on_off;
assign en_12v_bp = efuse_pwr_on_off;
assign en_bp_5v = efuse_pwr_on_off;
assign en_3v3_riser = efuse_pwr_on_off;

cpu_power_control cpu_pwr_control
(
.clock(clock),
.reset(reset),

.int_1ms_en(int_1ms_en),
.int_100ms_en(int_100ms_en),
.cpu_pwr_on_off(cpu_pwr_on_off),

.en_vddc_a(en_vddc_a),
.en_pcie_phy_a(en_pcie_phy_a),
.en_vddq_a0(en_vddq_a0),
.en_vddq_a1(en_vddq_a1),
.en_vpp_a0(en_vpp_a0),
.en_vpp_a1(en_vpp_a1),
.en_vtt_a0(en_vtt_a0),
.en_vtt_a1(en_vtt_a1),
.en_ddr_phy_a(en_ddr_phy_a),
.en_pcie_h_a(en_pcie_h_a),
.en_vqps18_a(en_vqps18_a),
.cpua_rst_pwr(cpua_rst_pwr),
.cpua_pwrok(cpua_pwrok),
.pwr_button_a(pwr_button_a),

.en_vddc_b(en_vddc_b),
.en_pcie_phy_b(en_pcie_phy_b),
.en_vddq_b0(en_vddq_b0),
.en_vddq_b1(en_vddq_b1),
.en_vpp_b0(en_vpp_b0),
.en_vpp_b1(en_vpp_b1),
.en_vtt_b0(en_vtt_b0),
.en_vtt_b1(en_vtt_b1),
.en_ddr_phy_b(en_ddr_phy_b),
.en_pcie_h_b(en_pcie_h_b),
.en_vqps18_b(en_vqps18_b),
.cpub_rst_pwr(cpub_rst_pwr),
.cpub_pwrok(cpub_pwrok),
.pwr_button_b(pwr_button_b),

.en_vdd_1v8(en_vdd_1v8),
.en_vdd_3v3(en_vdd_3v3),
.en_vdd_5v(en_vdd_5v)
);

// pcie switch 上电复位控制

//wire switch_prst;

switch_reset_control switch_reset_control
(
.clock(clock),
.reset(reset),
.int_1ms_en(int_1ms_en),
.switch_sys_rst(switch_sys_rst),
.switch_prst(switch_prst),
.pg_vdd_1v8(pg_vdd_1v8),
.en_pcie_sw_0v8_a(en_pcie_sw_0v8_a),
.en_pcie_sw_0v8_b(en_pcie_sw_0v8_b),
.pg_pcie_sw_0v8_a(pg_pcie_sw_0v8_a),
.pg_pcie_sw_0v8_b(pg_pcie_sw_0v8_b)
);



endmodule