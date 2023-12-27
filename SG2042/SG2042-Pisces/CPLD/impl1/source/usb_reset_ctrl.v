
module usb_reset_ctrl
(
input wire clock,
input wire reset,
input wire int_1ms_en,

input wire cpua_pwrok,

input wire rc_pcie_rst,

output reg  usb_ponrst,
output reg  usb_prst
);

wire pos_edge;
wire neg_edge;

reg sig_r0,sig_r1;//????ãÀ
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
			first_ponrst = 3'b001,
			neg_delay = 3'b010,
			pos_delay = 3'b011,
			low_delay = 3'b100,
			reset_stable = 3'b101;
			
always@(posedge clock )
begin
	if(!reset)
		current_state <= idle;
	else
		current_state <= next_state;
end

reg[15:0] urst_delay;
always@(*)
begin
	case(current_state)
		idle:
			begin
				if(cpua_pwrok==1'b1)
					next_state = first_ponrst;
				else
					next_state = idle;					
			end	
		
		first_ponrst:
			begin
				if(neg_edge==1'b1)
					next_state = neg_delay;
				else
					next_state = first_ponrst;
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
				if(urst_delay==16'd35000)
					next_state = reset_stable;
				else
					next_state = pos_delay;
			end


		reset_stable:
			begin
				if(cpua_pwrok==1'b0)
					next_state = idle;
				else
					next_state = reset_stable;
			end
			
			
	endcase
end


always@(posedge clock or negedge reset)
begin
	if(!reset)
		begin
			usb_ponrst<=1'b1;
			usb_prst<=1'b1;
			urst_delay<=16'd0;
		end
	else
		begin
			case(current_state)
				idle:
					begin
						if(cpua_pwrok==1'b1)
							begin
								usb_ponrst<=1'b0;
								usb_prst<=1'b1;
								urst_delay<=16'd0;
							end
						else
							begin
								usb_ponrst<=1'b1;
								usb_prst<=1'b1;
								urst_delay<=16'd0;
							end							
					end
	
				first_ponrst:
					begin
						if(int_1ms_en)
							begin
								urst_delay<=urst_delay+1'b1;
							end

						if(urst_delay==16'd100)
							begin
								usb_ponrst<=1'b1;
								usb_prst<=1'b1;
							end
					end

				neg_delay:
					begin
						usb_ponrst<=1'b1;
						usb_prst<=1'b0;
						urst_delay<=16'd0;
					end					
		
				pos_delay:
					begin
						if(int_1ms_en)
							begin
								urst_delay<=urst_delay+1'b1;
							end

						if(urst_delay==16'd20)
							begin
								usb_ponrst<=1'b1;
								usb_prst<=1'b1;
							end

						else if(urst_delay==16'd24000)
							begin
								usb_ponrst<=1'b0;
								usb_prst<=1'b1;
							end	
							
						else if(urst_delay==16'd24500)
							begin
								usb_ponrst<=1'b1;
								usb_prst<=1'b1;
							end	
							
						else if(urst_delay==16'd26000)
							begin
								usb_ponrst<=1'b1;
								usb_prst<=1'b0;
							end	
							
						else if(urst_delay==16'd26200)
							begin
								usb_ponrst<=1'b1;
								usb_prst<=1'b1;
							end								
							
						else if(urst_delay==16'd28000)
							begin
								usb_ponrst<=1'b0;
								usb_prst<=1'b1;
							end	
							
						else if(urst_delay==16'd28500)
							begin
								usb_ponrst<=1'b1;
								usb_prst<=1'b1;
							end							

					end

				reset_stable:
					begin
						usb_ponrst<=1'b1;
						usb_prst<=1'b1;
						urst_delay<=16'd0;
					end				
					
			endcase
		end
end

endmodule

