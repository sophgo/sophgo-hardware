//V1.1版本：增加reset拉低30ms再拉高的动作

module cpu_power_control
(
clock,
reset,
int_1ms_en,
int_100ms_en,

cpu_pwr_on_off,

en_vdd_1v8,
en_vdd_3v3,
en_vdd_5v,

en_vddc_a,
en_pcie_phy_a,
en_vddq_a0,
en_vddq_a1,
en_vpp_a0,
en_vpp_a1,
en_vtt_a0,
en_vtt_a1,
en_ddr_phy_a,
en_pcie_h_a,
en_vqps18_a,
cpua_rst_pwr,
cpua_pwrok,
pwr_button_a,

en_vddc_b,
en_pcie_phy_b,
en_vddq_b0,
en_vddq_b1,
en_vpp_b0,
en_vpp_b1,
en_vtt_b0,
en_vtt_b1,
en_ddr_phy_b,
en_pcie_h_b,
en_vqps18_b,
cpub_rst_pwr,
cpub_pwrok,
pwr_button_b
);

input wire clock;
input wire reset;
input wire int_1ms_en;
input wire int_100ms_en;
input wire cpu_pwr_on_off;

input wire cpua_pwrok;
input wire cpub_pwrok;

output wire en_vddc_a;
output wire en_pcie_phy_a;
output wire en_vddq_a0;
output wire en_vddq_a1;
output wire en_vpp_a0;
output wire en_vpp_a1;
output wire en_vtt_a0;
output wire en_vtt_a1;
output wire en_ddr_phy_a;
output wire en_pcie_h_a;
output wire en_vqps18_a;
output wire pwr_button_a;

output wire en_vddc_b;
output wire en_pcie_phy_b;
output wire en_vddq_b0;
output wire en_vddq_b1;
output wire en_vpp_b0;
output wire en_vpp_b1;
output wire en_vtt_b0;
output wire en_vtt_b1;
output wire en_ddr_phy_b;
output wire en_pcie_h_b;
output wire en_vqps18_b;
output wire pwr_button_b;

output wire en_vdd_1v8;
output wire en_vdd_3v3;
output wire en_vdd_5v;

output wire cpua_rst_pwr;
output wire cpub_rst_pwr; 

            

////////////////////////////////////////////////
//                                            //
//    三段式状态控制上下电时序                //
//                                            //
////////////////////////////////////////////////

reg[2:0] next_state;
reg[2:0] current_state;


localparam idle = 3'b000,
           power_on_sequence  = 3'b001,
		   reset_sequence	  = 3'b010,
		   power_on_steady    = 3'b011,
		   power_off_sequence = 3'b100;

wire cpu_pwrok;

assign cpu_pwrok = cpua_pwrok & cpub_pwrok;

reg[8:0]  enable_reg = 9'h00;

reg sys_rst_x;
reg pwr_all_on;

reg reset_done;

//第一殦??序逻辑，用于描述当前状态和下一状态的转换
always@(posedge clock or negedge reset)
	begin
		if(!reset) //低电平复位
			begin
				current_state<=idle;
			end
		else
			begin
				current_state<=next_state;
			end
	end

//第二殧??合逻辑，根据输入信号power_state的值，规定next_state如何转换
always@(*)
	begin
		case(current_state)
			idle:
				begin
					if((cpu_pwr_on_off==1)&&(cpu_pwrok==0)) //bmc发送上电命令、且当前CPU未上电，则下一状态进入上电流稍
						begin
							next_state=power_on_sequence; 
						end
					else
						begin
							next_state=idle; 
						end 
				end
			
			power_on_sequence:
				begin
					if(pwr_all_on==1)
						begin
							next_state=reset_sequence; 
						end
					else
						begin
							next_state=power_on_sequence; 
						end
				end

			reset_sequence:
				begin
					if(reset_done==1'b1)
						next_state=power_on_steady; 
					else
						next_state=reset_sequence; 				
				end

				
			power_on_steady:
				begin
					if(cpu_pwr_on_off==0)
						begin
							next_state=power_off_sequence; 
						end
					else
						begin
							next_state=power_on_steady; 
						end
				end	
				
			power_off_sequence:
				begin
					if(enable_reg==9'h00)
						begin
							next_state=idle; 
						end
					else
						begin
							next_state=power_off_sequence;
						end
				end			
		
		endcase
	end

//第三段：产生每个状态的输出信号


reg[10:0] seq_cnt; //时序计数
reg pwr_button;

always@(posedge clock or negedge reset)
	begin
		if(!reset)
			begin
				enable_reg<=9'h00;
				seq_cnt<=11'h00;
				sys_rst_x<=1'b0;
				pwr_button<=1'b0;
				pwr_all_on<=1'b0;
				reset_done<=1'b0;
			end
		else
			begin
				case(current_state)
					idle:
						begin
							enable_reg<=9'h00;
							seq_cnt<=11'h00;
							pwr_all_on<=1'b0;
							reset_done<=1'b0;
						end
					
					power_on_sequence:
						begin
							if(seq_cnt>=11'd15)
								begin
									sys_rst_x<=1'b1;
									enable_reg<=9'h1_f_f;
									seq_cnt<=11'd0;
									pwr_all_on<=1'b1;
								end
							else
								if(int_100ms_en)
									begin
										seq_cnt<=seq_cnt+1'b1;
										enable_reg<={enable_reg[7:0],1'b1};
										sys_rst_x<=1'b0;
										pwr_button<=1'b1;
									end
						end
						
					reset_sequence:
						begin
							if(int_1ms_en)
								begin
									seq_cnt<=seq_cnt+1'b1;
								end
							
							if(seq_cnt==11'd30)
								begin
									sys_rst_x<=1'b1;
									reset_done<=1'b0;
								end
							else if(seq_cnt==11'd60)
								begin
									sys_rst_x<=1'b1;
									reset_done<=1'b1;
								end
							// else if(seq_cnt==11'd90)
								// begin
									// sys_rst_x<=1'b1;
									// reset_done<=1'b1;
								// end			
						end
					
					power_on_steady:
						begin
							seq_cnt<=11'h00;
								sys_rst_x<=1'b1;
								enable_reg<=9'h1_f_f;							
						end
					
					power_off_sequence:
						begin
							sys_rst_x<=1'b0;
							pwr_button<=1'b0;
							if(int_1ms_en)
								enable_reg<={1'b0,enable_reg[8:1]};								
						end
				endcase
			end
		
	end


assign en_vdd_5v     =  enable_reg[0];
assign en_vdd_3v3    =  enable_reg[1];
assign en_vdd_1v8    =  enable_reg[2];

assign en_vddc_a     =  enable_reg[3];
assign en_ddr_phy_a  =  enable_reg[4];
assign en_pcie_phy_a =  enable_reg[4];
assign en_pcie_h_a   =  enable_reg[4];
assign en_vpp_a0     =  enable_reg[5];
assign en_vpp_a1     =  enable_reg[5];
assign en_vddq_a0    =  enable_reg[6];
assign en_vddq_a1    =  enable_reg[6];
assign en_vtt_a0     =  enable_reg[7];
assign en_vtt_a1     =  enable_reg[7];
assign en_vqps18_a   =  enable_reg[8];
assign cpua_rst_pwr  =  sys_rst_x;
assign pwr_button_a  =  pwr_button;

assign en_vddc_b     =  enable_reg[3];
assign en_ddr_phy_b  =  enable_reg[4];
assign en_pcie_phy_b =  enable_reg[4];
assign en_pcie_h_b   =  enable_reg[4];
assign en_vpp_b0     =  enable_reg[5];
assign en_vpp_b1     =  enable_reg[5];
assign en_vddq_b0    =  enable_reg[6];
assign en_vddq_b1    =  enable_reg[6];
assign en_vtt_b0     =  enable_reg[7];
assign en_vtt_b1     =  enable_reg[7];
assign en_vqps18_b   =  enable_reg[8];
assign cpub_rst_pwr  =  sys_rst_x;
assign pwr_button_b  =  pwr_button;

endmodule

