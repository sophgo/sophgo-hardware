
module bmc_reset_ctrl
(
input wire clock,
input wire reset,
input wire int_1ms_en,
input wire rc_pcie_rst,

output reg  bmc_srst,
output wire bmc_ssprst,
output wire bmc_extrst,
output wire  bmc_pcie_rst
);



reg[5:0] rst_in_dly = 6'd0;
wire rst_in;

always@(posedge clock)
begin
	rst_in_dly <= {rst_in_dly[4:0], 1'b1};	
end

assign rst_in = rst_in_dly[5];

reg[7:0] srst_delay;

always@(posedge clock or negedge reset)
begin
	if(!reset)
		begin
			bmc_srst<=1'b0;
			srst_delay<=8'd0;
		end
	else
		begin
			if(srst_delay==8'd100)
				begin
					bmc_srst<=1;
					srst_delay<=8'd10;
				end				
			else if(int_1ms_en)
				begin
					srst_delay<=srst_delay+1'b1;
				end
		end
end



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
		   sig_r0 <= rc_pcie_rst;
		   sig_r1 <= sig_r0;
		end
end
 
assign pos_edge = ~sig_r1 & sig_r0;
assign neg_edge = sig_r1 & ~sig_r0;

reg[2:0] current_state;
reg[2:0] next_state;

localparam 	idle = 3'b000,
			neg_delay = 3'b001,
			pos_delay = 3'b010,
			low_delay = 3'b011;

always@(posedge clock )
begin
	if(!reset)
		current_state <= idle;
	else
		current_state <= next_state;
end

reg[15:0] prst_delay;
always@(*)
begin
	case(current_state)
		idle:
			begin
				if(neg_edge==1'b1)
					next_state = neg_delay;
				else
					next_state = idle;
			end

		neg_delay:
			begin
				if(pos_edge==1'b1)
					next_state = pos_delay;
				else
					next_state = neg_delay;
			end

		pos_delay:
			begin
				if(neg_edge==1'b1)
					next_state = neg_delay;
				else
					next_state = pos_delay;
			end
	endcase
end

reg bmc_prst;

always@(posedge clock or negedge reset)
begin
	if(!reset)
		begin
			bmc_prst<=1'b0;
			prst_delay<=16'd0;
		end
	else
		begin
			case(current_state)
				idle:
					begin
						bmc_prst<=1'b0;
						prst_delay<=16'd0;
					end
					
				neg_delay:
					begin
						bmc_prst<=1'b0;
						prst_delay<=16'd0;
					end					
		
				pos_delay:
					begin
						if(prst_delay==16'd100)
							begin
								bmc_prst<=1'b1;
								prst_delay<=16'd100;
							end
						else if(int_1ms_en)
							begin
								//bmc_prst<=1'b0;
								prst_delay<=prst_delay+1'b1;							
							end
					end	
			endcase
		end
end

wire bmc_reset;

assign bmc_reset = bmc_srst;

assign bmc_ssprst   = bmc_reset;

assign bmc_extrst   = bmc_reset;

assign bmc_pcie_rst = bmc_prst;

endmodule
