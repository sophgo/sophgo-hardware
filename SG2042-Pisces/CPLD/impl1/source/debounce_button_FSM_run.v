
// Module Function:按键消抖
 
module debounce_button_FSM 
(
	clock,
	reset,
	int_1ms_en,
	key,
	key_out,
	key_pulse
);
 
	input wire  clock;
    input wire  reset;
	input wire int_1ms_en;
    input wire  key; 	//输入的按�
    output wire key_out;	
	output wire key_pulse;  	//按键动作产生的脉�
	wire key_neg;		//按键动作产生的脉�
    wire key_pos;
	wire key_sec;
    wire current_state_out_0;
    wire current_state_out_1;  
    reg[1:0]     current_state;                    //定义一个寄存器变量储存状�
    reg[1:0]     next_state;                    //定义一个寄存器变量储存状�
    reg     key_rst_pre;                //定义一个寄存器型变量存储上一个触发时的按键�
    reg     key_rst;                    //定义一个寄存器变量储存储当前时刻触发的按键�
 
always @(posedge clock  or  negedge reset)
    begin
        if (!reset) 
			begin
				key_rst <= 1'b1;                //初始化时给key_rst赋值全�，{}中表示N�
				key_rst_pre <= 1'b1;
			end
        else 
			begin
				key_rst <= key;                     //第一个时钟上升沿触发之后key的值赋给key_rst,同时key_rst的值赋给key_rst_pre
				key_rst_pre <= key_rst;             //非阻塞赋值。相当于经过两个时钟触发，key_rst存储的是当前时刻key的值，key_rst_pre存储的是前一个时钟的key的�
			end    
    end
assign  key_neg = key_rst_pre & (~key_rst);//脉冲边沿检测。当key检测到下降沿时，key_neg产生一个时钟周期的高电�
assign  key_pos = (~key_rst_pre) & key_rst;//脉冲边沿检测。当key检测到上升沿时，key_pos产生一个时钟周期的高电�
//利用非阻塞赋值特点，将两个时钟触发时按键状态存储在两个寄存器变量中
reg	[7:0]	  cnt;                       //产生延时所用的计数器，系统时钟25MHz，要延时20ms左右时间� 
//当检测到key_neg有效是计数器清零开始计数，产生20ms延时
always @(posedge clock or negedge reset)
	begin
		if(!reset)
            cnt <= 8'd0;
        else 
			if(key_neg || key_pos)
                cnt <= 8'd0;
			else
				if(cnt==8'd20)
					cnt <= 8'd0;
					else
						if(int_1ms_en)	//
							cnt <= cnt + 1'd1;
						else
							cnt <= cnt;
	end  
reg	sec_pre;                //延时后检测电平寄存器变量
reg	sec;                    
//延时20ms后检测再次检测key，sec改变
always @(posedge clock  or  negedge reset)
	begin
	if (!reset) 
		sec <= 1'b1;                
	else 
		if (cnt==8'd20)	begin
			sec <= key;  
		end
	end     	
always @(posedge clock  or  negedge reset)
	begin
		if (!reset)
			sec_pre <= 1'b1;
		else                   
			sec_pre <= sec;             
	end      
assign  key_pulse = ~sec_pre & sec;  //脉冲边沿检测。当sec检测到上降沿时，key_pulse产生一个时钟周期的高电�
reg	[7:0]	  cnt_time;                       //产生输出的拉低电平所用的计数器，系统时钟25MHz，要延时30ms左右时间�
always @(posedge clock or negedge reset)
	begin
		if(!reset)
            cnt_time <= 8'd0;
        else 
			if(key_pulse) 
                cnt_time <= 8'd0;
			else
				if(cnt_time==8'd30) 
					cnt_time <= 8'd0;
				else
					if(int_1ms_en) 	//
						cnt_time <= cnt_time + 1'd1;
					else
						cnt_time <= cnt_time;
	end 
 reg	out; 
always @(posedge clock  or  negedge reset)
    begin
        if (!reset) 
			begin
				current_state <= 2'b0;                //初始化时给current_state赋值为0
			end
        else 
			begin
				current_state <= next_state;                     
			end    
    end
	
always @(*)
    begin
        next_state = 2'b0;
        case(current_state)
            2'b0:   if (!sec)
                        next_state = 2'b1;
                        else if (sec)
                            next_state = 2'b0;
            2'b1:   if (sec)
                        next_state = 2'b10;
                        else if (!sec)
                        next_state = 2'b1;
            2'b10:   if (cnt_time == 8'd30)
                        next_state = 2'b0; 
                        else if (!(cnt_time == 8'd30))   
                            next_state = 2'b10;      
        endcase
    end
	
always @(posedge clock  or  negedge reset)
    begin
        if (!reset)
            out <= 8'b1;
        else
            case(current_state)
            2'b0:   out <= 1;
            2'b1:   out <= 1;
            2'b10:  out <= 0;
            endcase
    end

assign key_out = out;
assign key_sec = sec; 
assign current_state_out_0 = current_state[0];
assign current_state_out_1 = current_state[1];
 
endmodule


