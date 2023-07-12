module power_on_reset  
(
clock,
rst_btn,
bmc_cpld_rst,
power_ok ,
reset
);

input  clock;
input  rst_btn;
input  bmc_cpld_rst;
input  power_ok ;
output reset;

wire clock;
wire rst_btn;
wire reset;

reg[5:0] rst_btn_dly = 6'd0;

//------------------------------------------
// Delay 100ms for steady state


always@(posedge clock)
begin
	rst_btn_dly <= {rst_btn_dly[4:0], rst_btn};	
end

assign  reset = (&(rst_btn_dly[5:1])) & power_ok & bmc_cpld_rst;


endmodule

