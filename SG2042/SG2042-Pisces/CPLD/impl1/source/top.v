
//SG2042 服务器
module server_top
(
//时钟和复位
clock,  		//全局25MHz时钟输入，
cpld_extrst,    //CPLD_BMC_EXTRST_N，按键输入
//fp_rst_btn, 	//前面板复位按键

//外部电源按键
//fp_pwr_btn,
fm_pwr_btn,


//bmc信号
//cpu_reset,
bmc_srst,
bmc_ssprst,
bmc_extrst,

bmc_pcie_rst,
bmc_pwrgd,

//board power enable and power good
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

en_vdd_1v8,
en_vdd_3v3,
en_vdd_5v,

pg_vddc_a,
pg_pcie_phy_a,
pg_vddq_a0,
pg_vddq_a1,
pg_vpp_a0,
pg_vpp_a1,
pg_vtt_a0,
pg_vtt_a1,
pg_ddr_phy_a,
pg_pcie_h_a,

pg_vddc_b,
pg_pcie_phy_b,
pg_vddq_b0,
pg_vddq_b1,
pg_vpp_b0,
pg_vpp_b1,
pg_vtt_b0,
pg_vtt_b1,
pg_ddr_phy_b,
pg_pcie_h_b,

pg_vdd_1v8,
pg_vdd_3v3,
pg_vdd_5v,

//pg misc
pg_5v_aux,
pg_bp_5v,
pg_3v3_riser,

//efuse
en_vdd_12v,
ncp0_d_oc,
ncp0_gok,

en_12v_bp,
bp_ncp_d_oc,
bp_ncp_gok,

//psu control
psu0_pwrok,
psu1_pwrok,
psu0_alert,
psu1_alert,
psu0_prsnt,
psu1_prsnt,
//ac_loss_n,
psu_ps_on_cpld,

//pcie switch power
en_pcie_sw_0v8_a,
en_pcie_sw_0v8_b,
pg_pcie_sw_0v8_a,
pg_pcie_sw_0v8_b,

//reset control
cpua_sys_reset,
cpub_sys_reset,

//sg0_pcie0_l0_reset,
sg0_pcie1_l0_reset,

sg1_pcie0_l0_reset,
//sg1_pcie1_l0_reset,

pcie_swa_sys_rst,
pcie_swb_sys_rst,
pcie_swa_prst,
pcie_swb_prst,


pcie_nvme0_rst,
pcie_nvme1_rst,
pcie_usb0_rst,
pcie_usb1_rst,
pcie_sata_rst,

usb1_ponrst,
usb2_ponrst,

//slot control
riser0_slot_id0,
riser0_slot_id1,
riser0_slot_id2,
riser0_slot16a_prsnt,
riser0_slot16b_prsnt,

riser1_slot_id0,
riser1_slot_id1,
riser1_slot_id2,
riser1_slot16a_prsnt,
riser1_slot16b_prsnt,

riser2_slot_id0,
riser2_slot_id1,
riser2_slot16b_prsnt,

riser0_reset,
riser1_reset,
riser2_reset,

en_3v3_riser,
en_bp_5v,

//ddr event信号
ddr0_event_a,
ddr1_event_a,
ddr2_event_a,
ddr3_event_a,
ddr0_event_b,
ddr1_event_b,
ddr2_event_b,
ddr3_event_b,

//bmc i2c信号
bmc_sda,
bmc_scl,

//eeprom管
e2prom_scl,
e2prom_sda,

//cpu ctrl
pwr_button_a,
pwr_button_b,

//uart
sys_uart_txd3,
sys_uart_rxd3,

uart0_tx_a,
uart0_rx_a,

uart1_tx_a,
uart1_rx_a,

uart0_tx_b,
uart0_rx_b,

uart1_tx_b,
uart1_rx_b,

//bmc gpio//

bmc_gpio24,
bmc_gpio25,
bmc_gpio48,//BMC_PowerOut
bmc_gpio49,//BMC_Reset_out
bmc_gpio51,//PowerOK
bmc_gpio53,//reset button
bmc_gpio54,//power button

//host gpio
a_gpio2,
a_gpio3,
a_gpio5,
a_gpio16,

//vga
vga_6505_in1,
vga_6505_in2,
//vga_front_prsnt,

//test信号
//sig_test,

//LED信号
cpld_heart,
cpld_led_test

);

///**************************************************************************************///
//                                                                                        //
//                         时钟定义                                                   //
//                                                                                        //
///**************************************************************************************///
//全局时钟入
input wire  clock;
output wire cpld_heart;

///**************************************************************************************///
//                                                                                        //
//                        CPU控制引脚定义                                                   //
//                                                                                        //
///**************************************************************************************///
wire pwr_button_a0;
wire pwr_button_b0;

output wire pwr_button_a;
output wire pwr_button_b;

assign pwr_button_a  =  1'b1;//pwr_button_a0;
assign pwr_button_b  =  1'b1;//pwr_button_b0;

///**************************************************************************************///
//                                                                                        //
//                         VGA                                                            //
//                                                                                        //
///**************************************************************************************///

output wire vga_6505_in1;
output wire vga_6505_in2;
//input wire vga_front_prsnt;

assign vga_6505_in1 = 1'b0;//(vga_front_prsnt==1'b0)?1'b1:1'b0;
assign vga_6505_in2 = 1'b0;//(vga_front_prsnt==1'b0)?1'b1:1'b0;

///**************************************************************************************///
//                                                                                        //
//                         register define                                                //
//                                                                                        //
///**************************************************************************************///
//cpld_register_addr,rd_wr_flag,bmc_read_data,bmc_write_data
//register define
wire[7:0]	hardware_version;                       //addr:0x00
wire[7:0] 	cpld_version;                           //addr:0x01
reg[7:0]  	power_control = 7'h00;                  //addr:0x02
wire[7:0] 	cpua_power_status;                      //addr:0x03
wire[7:0]	cpub_power_status;                      //addr:0x04
wire[7:0] 	cpu_pwr_status_misc;                    //addr:0x05 
wire[7:0] 	power_status_misc;                      //addr:0x06
wire[7:0] 	psu_status;                             //addr:0x07
wire[7:0] 	efuse_status;                           //addr:0x08
reg[7:0] 	reset_control_a ;//= 7'hFF;             //addr:0x09 
reg[7:0]	reset_control_b ;//= 7'hFF;             //addr:0x0A
wire[7:0] 	riser_id_detect_a;                      //addr:0x0B
wire[7:0] 	riser_id_detect_b;                      //addr:0x0C
reg[7:0]  	riser_reset;                            //addr:0x0D
reg[7:0]  	e2prom_dev_addr;      		             //addr:0x12
reg[7:0]  	e2prom_byte_addr ;    		             //addr:0x13
reg[7:0]  	e2prom_data_wr ;      		             //addr:0x14
wire[7:0] 	e2prom_data_rd ;      		             //addr:0x15
wire[7:0]   ddr_event;
									                
wire[7:0]  build_month;         //addr:0x11
wire[7:0]  build_date;          //addr:0x12
reg[7:0] test_register;         //addr:0x20

wire[9:0] e2prom_word_addr ;

///**************************************************************************************///
//                         register 赋值                                                  //
///**************************************************************************************///
input wire riser0_slot_id0;
input wire riser0_slot_id1;
input wire riser0_slot_id2;
input wire riser0_slot16a_prsnt;
input wire riser0_slot16b_prsnt;

input wire riser1_slot_id0;
input wire riser1_slot_id1;
input wire riser1_slot_id2;
input wire riser1_slot16a_prsnt;
input wire riser1_slot16b_prsnt;

input wire riser2_slot_id0;
input wire riser2_slot_id1;
input wire riser2_slot16b_prsnt;

assign riser_id_detect_a = {1'b0,1'b0,1'b0,riser0_slot_id0,riser0_slot_id1,riser0_slot_id2,riser0_slot16a_prsnt,riser0_slot16b_prsnt};
assign riser_id_detect_b = {riser1_slot_id0,riser1_slot_id1,riser1_slot_id2,riser1_slot16a_prsnt,riser1_slot16b_prsnt,riser2_slot_id0,riser2_slot_id1,riser2_slot16b_prsnt};

input wire ddr0_event_a;
input wire ddr1_event_a;
input wire ddr2_event_a;
input wire ddr3_event_a;

input wire ddr0_event_b;
input wire ddr1_event_b;
input wire ddr2_event_b;
input wire ddr3_event_b;

assign ddr_event = {ddr3_event_b,ddr2_event_b,ddr1_event_b,ddr0_event_b,ddr3_event_a,ddr2_event_a,ddr1_event_a,ddr0_event_a};


///**************************************************************************************///
//                                                                                        //
//                         电源和复位按键控制模块                                          //
//                                                                                        //
///**************************************************************************************///

//input wire fp_pwr_btn;
input wire fm_pwr_btn;

wire pwr_btn;
assign pwr_btn =  fm_pwr_btn;//fp_pwr_btn &  //前面板和后面板的按键做与逻辑

input wire cpld_extrst;
//input wire fp_rst_btn;

wire rst_btn;

assign rst_btn = cpld_extrst ;//& fp_rst_btn;

wire bmc_cpld_rst;
//input wire bmc_gpio49;
assign bmc_cpld_rst = 1'b1;//bmc_gpio49;// reset_control_a[7];

wire reset;

wire cpu_pwrok;
wire power_on;

wire power_ok;
assign power_ok=1'b1;


output wire bmc_gpio54;
output wire bmc_gpio53;

assign bmc_gpio54 = pwr_btn;
assign bmc_gpio53 = rst_btn;

//**************************************************************************************///
//                        上电复位                                                       //
///**************************************************************************************///
power_on_reset  por
(
.clock(clock),
.rst_btn(1'b1),
.bmc_cpld_rst(1'b1),
.power_ok(1'b1) ,
.reset(reset)
);

//**************************************************************************************///
//                         计时器模块                                                  //
///**************************************************************************************///
//1ms计时器，每个1ms产生一个脉冲
wire int_1ms_en;
wire int_100ms_en;

timer timer_inst
(
.clock(clock),
.reset(reset),
.int_1ms_en(int_1ms_en),
.int_100ms_en(int_100ms_en)
);

//**************************************************************************************///
//                         UART SOL                                                      //
///**************************************************************************************///
input wire sys_uart_txd3;
 output wire sys_uart_rxd3;

 input wire uart0_tx_a;
 output wire uart0_rx_a;

 input wire uart1_tx_a;
 output wire uart1_rx_a;

 input wire uart0_tx_b;
 output wire uart0_rx_b;

 input wire uart1_tx_b;
 output wire uart1_rx_b;


 input wire bmc_gpio24;
 input wire bmc_gpio25;

 uart_sol uart_sol_inst
 (
 .sys_uart_txd3(sys_uart_txd3),
 .sys_uart_rxd3(sys_uart_rxd3),
 .uart0_tx_a(uart0_tx_a),
 .uart0_rx_a(uart0_rx_a),
 .uart1_tx_a(uart1_tx_a),
 .uart1_rx_a(uart1_rx_a),
 .uart0_tx_b(uart0_tx_b),
 .uart0_rx_b(uart0_rx_b),
 .uart1_tx_b(uart1_tx_b),
 .uart1_rx_b(uart1_rx_b),
 .BMC_GPIO24(bmc_gpio24),
 .BMC_GPIO25(bmc_gpio25),
 .reset(reset)
 );


///**************************************************************************************///
//                                                                                        //
//                       i2c slave  register read/write                                   //
//                                                                                        //
///**************************************************************************************///
//i2c0 端口信号
inout  bmc_sda;
inout  bmc_scl;

//bmc i2c0 双向端口数据处理
wire bmc_sda_in;
wire bmc_sda_out;

//i2c slave 需要的数据接口
//wire [6:0] device_addr_in;
wire [7:0] cpld_register_addr;
wire [7:0] bmc_write_data;
wire [7:0] bmc_read_data;

wire i2c0_stretch_en;

assign i2c0_stretch_en = 1'b1;

//双向SDA处理方式
assign bmc_sda = (reg_i2c0_is_slave_send)? bmc_sda_out:1'bz;
assign bmc_sda_in = bmc_sda;

wire bmc_scl_in;
assign bmc_scl_in = bmc_scl;
assign bmc_scl = (i2c0_stretch_en)? 1'b0:1'bz;

assign e2prom_word_addr={e2prom_dev_addr[1:0],e2prom_byte_addr};

//模块例化
///**************************************************************************************///
//                         i2c0 slave                                          //
///**************************************************************************************///
wire[6:0] slave_addr;
assign slave_addr = 7'h57;

i2c_slave_reg  
#(
	.CAS_MODE(1'b0)
) i2c0_slave_inst0
(
	.clk(clock), 
	.rst_n(reset), 		
	.scl_in(bmc_scl_in) ,    
	.sda_in(bmc_sda_in) ,
	.int_1ms_en(int_1ms_en) ,
	.slave_addr(slave_addr),
	.rd_data(bmc_read_data),
	.word_addr(cpld_register_addr),
	.word_addr_vld(),
	.wr_data(bmc_write_data),
	.wr_data_vld(wr_data_vld),
	.sda_out(bmc_sda_out),
	.is_slave_send(reg_i2c0_is_slave_send),
	.scl_cas_in(),
	.sda_cas_in(),
	.mux_clk_en(),
	.mux_data_en(),
	.slave_addr_out() ,
	.scl_cas_out_en(),
	.stretch_en()
);

///**************************************************************************************///
//                         register read&write                                            //
///**************************************************************************************///

//版本信息管脚
wire[8:0] pcb_version;
wire[8:0] bom_version;

assign pcb_version = 8'h11;
assign bom_version = 8'h10;


//只读寄存器赋值
assign hardware_version = {bom_version,pcb_version};
assign cpld_version     = 8'h11;  //version 1.1

assign build_month      =  8'd5;
assign build_date       =  8'd22; 

//寄存器读写模坊
//wire[7:0] cpld_register_addr;
reg [7:0] data_out_r;
assign bmc_read_data = data_out_r;

reg test_interrupt;

//寄存器寻址访问
always@(posedge clock or negedge reset)
 begin
  if(!reset)
   begin
    power_control <= 8'h00;
    reset_control_a <=8'hFF;
    reset_control_b <= 8'hFF;
    riser_reset <=8'h00;	
    e2prom_dev_addr <=8'h00;      //addr:0x0D
    e2prom_byte_addr  <=8'h00;    //addr:0x0E
    e2prom_data_wr  <=8'h00;	
	test_register<=8'h55;
    data_out_r<=8'h00;
	test_interrupt <= 1'b0;
	//e2prom_word_addr <= 10'd0;
	e2prom_data_wr <= 8'd0;
   end
  else
   begin
    if(wr_data_vld)
     begin	  // 写寄存器
      case(cpld_register_addr)
       8'h02:
        power_control    <= bmc_write_data;
       8'h09:
        reset_control_a  <= bmc_write_data;
       8'h0A:
        reset_control_b  <= bmc_write_data;	     		
       8'h0D:
        riser_reset      <= bmc_write_data;       	   
	   8'h12:
	    e2prom_dev_addr  <=  bmc_write_data;
	   8'h13:
	    e2prom_byte_addr <=  bmc_write_data;
	   8'h14:
	     e2prom_data_wr  <= bmc_write_data;
	   8'h22:
	     test_register   <=  bmc_write_data;
	   8'h23:
	    if (bmc_write_data  == 8'hA5)   // 
			test_interrupt <= 1'b1;
		else
			test_interrupt <= 1'b0;			
      endcase
     end
    else
 	  begin
       case(cpld_register_addr)
	    8'h00:
         data_out_r <= hardware_version;
	    8'h01:
         data_out_r <= cpld_version;	   
	    8'h02:
         data_out_r <= power_control;
	    8'h03:
         data_out_r <= cpua_power_status;
	    8'h04:
         data_out_r <= cpub_power_status;
		8'h05:
         data_out_r <= cpu_pwr_status_misc;	   
	    8'h06:
         data_out_r <= power_status_misc;
	    8'h07:
         data_out_r <= psu_status;
	    8'h08:
         data_out_r <= efuse_status;
	    8'h09:
         data_out_r <= reset_control_a;
	    8'h0A:
         data_out_r <= reset_control_b; 
	    8'h0B:
         data_out_r <= riser_id_detect_a;  
	    8'h0C:
         data_out_r <= riser_id_detect_b;	
	    8'h0D:
         data_out_r <= riser_reset;
		8'h12:
         data_out_r <= e2prom_dev_addr;//{6'd0,e2prom_word_addr[9:8]};
		8'h13:
		 data_out_r <= e2prom_byte_addr[7:0];
		8'h14:
		 data_out_r <=  e2prom_data_rd; 
		8'h15:
		 data_out_r <=  ddr_event; 
		8'h20:
         data_out_r <= build_month;
		8'h21:
         data_out_r <= build_date;	
		8'h22:
		 data_out_r <= test_register;
		8'h23:
		 data_out_r <= {7'd0,test_interrupt};
		//8'h24: 
		//data_out_r <= mcu_scl_gd_det ;
        		 
  	    default:data_out_r <= 8'h00;
       endcase 
	  end
   end
 end
///**************************************************************************************///
//                                  单板上下电流程                                        //
///**************************************************************************************///
input wire psu0_pwrok;
input wire psu1_pwrok;
input wire psu0_alert;
input wire psu1_alert;
input wire psu0_prsnt;
input wire psu1_prsnt;
output wire psu_ps_on_cpld; //psu 信号

input wire pg_vddc_a;
input wire pg_pcie_phy_a;
input wire pg_vddq_a0;
input wire pg_vddq_a1;
input wire pg_vpp_a0;
input wire pg_vpp_a1;
input wire pg_vtt_a0;
input wire pg_vtt_a1;
input wire pg_ddr_phy_a;
input wire pg_pcie_h_a;
input wire pg_vddc_b;

input wire pg_pcie_phy_b;
input wire pg_vddq_b0;
input wire pg_vddq_b1;
input wire pg_vpp_b0;
input wire pg_vpp_b1;
input wire pg_vtt_b0;
input wire pg_vtt_b1;
input wire pg_ddr_phy_b;
input wire pg_pcie_h_b;

input wire pg_vdd_1v8;
input wire pg_vdd_3v3;
input wire pg_vdd_5v;

input wire pg_pcie_sw_0v8_a;
input wire pg_pcie_sw_0v8_b;

input wire pg_5v_aux;
input wire pg_bp_5v;
input wire pg_3v3_riser;

output wire en_vdd_1v8;
output wire en_vdd_3v3;
output wire en_vdd_5v;

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
output wire en_vqps18_b; //cpu电源信号

output wire en_pcie_sw_0v8_a;
output wire en_pcie_sw_0v8_b;

output wire en_vdd_12v;
input wire ncp0_d_oc;
input wire ncp0_gok;

output wire en_12v_bp;
input wire bp_ncp_d_oc;
input wire bp_ncp_gok;

output wire en_3v3_riser;
output wire en_bp_5v;

output wire bmc_pwrgd;

assign  cpua_power_status   =  {pg_vddc_a,pg_pcie_phy_a,pg_vtt_a0,pg_vtt_a1,pg_vddq_a0,pg_vddq_a1,pg_vpp_a0,pg_vpp_a1};
assign  cpub_power_status   =  {pg_vddc_b,pg_pcie_phy_b,pg_vtt_b0,pg_vtt_b1,pg_vddq_b0,pg_vddq_b1,pg_vpp_b0,pg_vpp_b1};
assign  cpu_pwr_status_misc =  {1'b0,1'b0,pg_ddr_phy_a,pg_pcie_h_a,pg_ddr_phy_b,pg_pcie_h_b,pg_vdd_1v8,pg_vdd_3v3};
assign  power_status_misc   =  {1'b0,1'b0,pg_pcie_sw_0v8_a,pg_pcie_sw_0v8_b,pg_vdd_5v,pg_5v_aux,pg_bp_5v,pg_3v3_riser};
assign  psu_status          =  {1'b0,1'b0,psu0_pwrok,psu1_pwrok,psu0_alert,psu1_alert,psu0_prsnt,psu1_prsnt};
assign  efuse_status        =  {1'b0,1'b0,1'b0,1'b0,bp_ncp_d_oc,bp_ncp_gok,ncp0_d_oc,ncp0_gok};

wire cpua_rst_pwr;
wire cpub_rst_pwr; //上下电过程中对CPU_SYS_RESET做操作
wire cpua_pwrok;
wire cpub_pwrok;

assign  cpua_pwrok = (& cpua_power_status) & pg_ddr_phy_a & pg_pcie_h_a & pg_vdd_1v8 & pg_vdd_3v3 & cpua_rst_pwr;
assign  cpub_pwrok = (& cpub_power_status) & pg_ddr_phy_b & pg_pcie_h_b & pg_vdd_1v8 & pg_vdd_3v3 & cpub_rst_pwr;

assign  bmc_pwrgd = cpua_pwrok & cpub_pwrok & pg_pcie_sw_0v8_a & pg_pcie_sw_0v8_b & pg_vdd_5v & pg_5v_aux & pg_bp_5v & pg_3v3_riser;

assign cpu_pwrok = cpua_pwrok & cpub_pwrok;

wire switch_sys_rst;
wire switch_prst;

input wire bmc_gpio48;
input wire bmc_gpio49;

wire bmc_power_out;
wire bmc_reset_out;

assign bmc_power_out = bmc_gpio48;
assign bmc_reset_out = bmc_gpio49;

wire host_pwr_off;
wire post_complete;

output wire a_gpio2;
input wire a_gpio3;
input wire a_gpio5;
input wire a_gpio16;
wire host_reboot;

assign a_gpio2 = host_pwr_off;
assign post_complete = a_gpio3;
assign host_reboot = a_gpio5;

output wire bmc_gpio51;
assign bmc_gpio51 = cpua_pwrok & cpub_pwrok ;//a_gpio16;////& pg_pcie_sw_0v8_a & pg_pcie_sw_0v8_b & pg_vdd_5v & pg_5v_aux & pg_bp_5v & pg_3v3_riser;

//wire pwr_button_a0;
//wire pwr_button_b0;
assign cpld_heart = host_pwr_off;

server_power_control server_power_control
(
.clock(clock),
.reset(reset),
.int_1ms_en(int_1ms_en),
.int_100ms_en(int_100ms_en),

.rst_btn(rst_btn),//本地复位按键
.pwr_btn(pwr_btn),//本地按键处理

.bmc_power_out(bmc_power_out),//bmc 输出给CPLD的电源控制信号
.bmc_reset_out(bmc_reset_out),//bmc 输出给CPLD的复位控制信号

.host_pwr_off(host_pwr_off), //cpld输出给Host，表示CPU要开始做下电操作
.post_complete(post_complete),//host输出给CPLD，表示完成软件操作，需要开始下电
.host_reboot(host_reboot), //host输出给CPLD，表示软件复位

//psu control
.psu0_pwrok(psu0_pwrok),
.psu1_pwrok(psu1_pwrok),
.psu_ps_on_cpld(psu_ps_on_cpld),

//efuse
.en_vdd_12v(en_vdd_12v),
.ncp0_gok(ncp0_gok),
.en_12v_bp(en_12v_bp),
.bp_ncp_gok(bp_ncp_gok),

//pg misc
.en_bp_5v(en_bp_5v),
.en_3v3_riser(en_3v3_riser),

//cpu power
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
.pwr_button_a(pwr_button_a0),

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
.pwr_button_b(pwr_button_b0),

.en_vdd_1v8(en_vdd_1v8),
.en_vdd_3v3(en_vdd_3v3),
.en_vdd_5v(en_vdd_5v),

//switch power
.switch_sys_rst(switch_sys_rst),
.switch_prst(switch_prst),
.pg_vdd_1v8(pg_vdd_1v8),
.en_pcie_sw_0v8_a(en_pcie_sw_0v8_a),
.en_pcie_sw_0v8_b(en_pcie_sw_0v8_b),
.pg_pcie_sw_0v8_a(pg_pcie_sw_0v8_a),
.pg_pcie_sw_0v8_b(pg_pcie_sw_0v8_b)
);



///**************************************************************************************///
//                                  复位处理                                              //
///**************************************************************************************///
//input wire sg0_pcie0_l0_reset;
//input  wire cpu_reset;
//output wire bmc_ssprst;

input wire sg0_pcie1_l0_reset;

input wire sg1_pcie0_l0_reset;
//input wire sg1_pcie1_l0_reset;

output wire cpua_sys_reset;
output wire cpub_sys_reset;

output wire pcie_swa_sys_rst;
output wire pcie_swb_sys_rst;
output wire pcie_swa_prst;
output wire pcie_swb_prst;

output wire pcie_nvme0_rst;
output wire pcie_nvme1_rst;
output wire pcie_usb0_rst;
output wire pcie_usb1_rst;
output wire pcie_sata_rst;

output wire riser0_reset;
output wire riser1_reset;
output wire riser2_reset;

assign cpua_sys_reset   = cpua_rst_pwr ;
assign cpub_sys_reset   = cpub_rst_pwr ;
assign pcie_swa_sys_rst = switch_sys_rst;// & reset_control_a[4];
assign pcie_swb_sys_rst = switch_sys_rst;// & reset_control_a[3];
assign pcie_swa_prst    = sg0_pcie1_l0_reset;
assign pcie_swb_prst    = sg1_pcie0_l0_reset;

assign riser2_reset     = reset & sg1_pcie0_l0_reset & reset_control_b[7];
assign riser1_reset     = reset & sg1_pcie0_l0_reset & reset_control_b[6];
assign riser0_reset     = reset & sg0_pcie1_l0_reset & reset_control_b[6];
assign pcie_nvme1_rst   = reset & sg0_pcie1_l0_reset & reset_control_b[4];
assign pcie_nvme0_rst   = reset & sg0_pcie1_l0_reset & reset_control_b[3];
assign pcie_sata_rst    = reset & sg0_pcie1_l0_reset & reset_control_b[2];


////////////USB Reset Control////////
output wire usb1_ponrst;
output wire usb2_ponrst;

wire usb_ponrst;
wire usb_prst;

usb_reset_ctrl usb_reset_ctrl_inst
(
.clock(clock),
.int_1ms_en(int_1ms_en),
.reset(reset),

.rc_pcie_rst(sg0_pcie1_l0_reset),
.cpua_pwrok(cpua_rst_pwr),

.usb_ponrst(usb_ponrst),
.usb_prst(usb_prst)
);

assign pcie_usb1_rst    = usb_prst;//sg0_pcie1_l0_reset;
assign pcie_usb0_rst    = usb_prst;//sg0_pcie1_l0_reset;

assign usb1_ponrst = usb_ponrst;
assign usb2_ponrst = usb_ponrst;

////////////BMC Reset Control////////
output wire bmc_srst;
output wire bmc_ssprst;
output wire bmc_extrst;
output wire bmc_pcie_rst;

bmc_reset_ctrl bmc_reset_ctrl_inst
(
.clock(clock),
.int_1ms_en(int_1ms_en),
.reset(reset),

.rc_pcie_rst(sg0_pcie1_l0_reset),

.bmc_srst(bmc_srst),
.bmc_ssprst(bmc_ssprst),
.bmc_extrst(bmc_extrst),
.bmc_pcie_rst(bmc_pcie_rst)
);

assign bmc_ssprst  = bmc_srst;
assign bmc_extrst  = bmc_srst;

///**************************************************************************************///
//                                  1s 闪烁信号                                            //
///**************************************************************************************///

output  cpld_led_test;

reg flash_1s;
reg[3:0] flash_clk_cnt;

always@(posedge clock or negedge reset)
 begin
  if(!reset)
   begin
    flash_clk_cnt<= 4'd0;
	flash_1s<=1'b0;
   end
  else
	if (int_100ms_en)
	begin
		if(flash_clk_cnt== 4'd9)  //25M时钟计时
		begin
			flash_clk_cnt<=4'd0;
			flash_1s<=~flash_1s;
		end
		else	
		begin
			flash_clk_cnt<=flash_clk_cnt+1'b1;
		end
	 end
 end

assign cpld_led_test = flash_1s ;

 
///**************************************************************************************///
//                                                                                        //
//                                  eeprom 读写                                           //
//                                                                                        //
///**************************************************************************************///
inout e2prom_scl;
inout e2prom_sda;

reg  start_e2prom ;
reg  e2prom_is_rw ;

wire  e2prom_scl_out ;
wire  e2prom_sda_out ;
wire  e2prom_scl_out_en ;
wire  e2prom_sda_out_en ;


always@(posedge clock or negedge reset)
 begin
  if(!reset)
  begin
	start_e2prom <= 1'b0;
	e2prom_is_rw <= 1'b1;
  end
  else
  begin
	if ((cpld_register_addr == 8'h0e) && (wr_data_vld == 1'b1))
	begin
		start_e2prom <= 1'b1;
		e2prom_is_rw <= 1'b1;
	end
	else if ((cpld_register_addr == 8'h10) && (wr_data_vld == 1'b1))  //write e2prom
	begin
		start_e2prom <= 1'b1;
		e2prom_is_rw <= 1'b0;
	end
	else
		start_e2prom <= 1'b0;
   end
end
		
 
 eeprom_i2c eeprom_i2c_inst
(
	.clk(clock), 
	.rst_n(reset), 
	.int_1ms_en(int_1ms_en),
	
	.word_addr(e2prom_word_addr),
	.data_write_in(e2prom_data_wr),
	.data_read_out (e2prom_data_rd),
	.is_rw(e2prom_is_rw),
	.start_sig(start_e2prom),
	
	.scl_in(e2prom_scl) ,    
	.sda_in(e2prom_sda) ,
	.scl_out(e2prom_scl_out),
	.sda_out(e2prom_sda_out),
	.scl_out_en(e2prom_scl_out_en),
	.sda_out_en(e2prom_sda_out_en)
);
 
assign  e2prom_scl = (e2prom_scl_out_en)? e2prom_scl_out:1'bz;
assign  e2prom_sda = (e2prom_sda_out_en)? e2prom_sda_out:1'bz;
 
endmodule
