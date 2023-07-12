
module i2c_slave_reg
#(
	parameter	I2C_SPEED_DIV 	=	10'd250,
	parameter   CAS_MODE        =   1'b1,
	parameter	SLAVE_ADDR_MIN  =   7'h38,
	parameter   SLAVE_ADDR_MAX  =   7'h3f,
	parameter   SLAVE_ADDR_OTHER     =   7'h38
)
(
	input			clk, 
	input   		rst_n, 		
	input           scl_in ,    
	input           sda_in ,
	input			int_1ms_en ,
	input[6:0]      slave_addr,
	input[7:0]		rd_data,
	output reg[7:0]	word_addr,
	output reg      word_addr_vld ,
	output reg[7:0]	wr_data,
	output reg 		wr_data_vld,

	output          sda_out ,
	output	reg     is_slave_send,
	////////////////////////cas port////////////
	input          scl_cas_in,
	input          sda_cas_in,

	output reg[6:0]	slave_addr_out ,
	output reg      mux_clk_en ,
	output reg      mux_data_en ,
	output reg      scl_cas_out_en ,
	output reg      stretch_en
);


wire  start ;
wire  stop  ;  
reg   stop_1d ;
reg   sda_out_reg = 1'b1 ;
reg   sda_out_mux = 1'b1 ;

reg   slave_addr_vld ;
wire  start_send_wait ;

reg[3:0]   next_state;
reg[3:0]   current_state;  
reg[3:0]   before_state ;
reg[2:0]   bit_cnt;
reg[7:0]   delay_cnt;
reg		   delay_cnt_en;
reg[7:0]   rcv_bit ;
reg        start_next_bit;
reg[5:0]   scl_in_dly = 6'b111111 ;
reg[5:0]   sda_in_dly = 6'b111111 ;

reg[1:0]   scl_cas_in_dly = 2'b11 ;
reg[1:0]   sda_cas_in_dly = 2'b11 ;
reg		   scl_cas_in_clean ;
reg        sda_cas_in_clean ;

reg        start_next_bit_1d ;
reg        scl_in_clean  = 1'b1;
reg[1:0]   scl_in_clean_dly =2'b11;
reg[1:0]   sda_in_clean_dly =2'b11;
reg        sda_in_clean  =1'b1;  

reg        opcode ;   
reg        start_en ;

reg[4:0]	timeout_cnt ;
reg         timeout_cnt_en ;
reg         time_out_en ;

/////////////////////////////////////////////

reg     start_stretch_det;	 
reg     stretch_en_1d ;

reg[8:0]  stretch_cnt ;
reg      stretch_cnt_en ;
reg[1:0]  start_stretch_det_dly ;
reg[4:0]  det_delay_cnt ;	
reg       rcv_cas_ack ;
reg       rcv_ack ;
 localparam  IDLE              =  4'd0,
		   DEV_ADDR_STATE    =  4'd1,
		   WAIT_ACK          =  4'd2,
		   WORD_ADDR_STATE   =  4'd3,
		   SEND_ACK          =  4'd4,
		   SEND_DATA         =  4'd5,
		   RCV_DATA		     =  4'd6;

/* remove small spur */
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		scl_in_dly <= 6'b111111;
		sda_in_dly <= 6'b111111;
		scl_cas_in_dly <= 2'b11;
		sda_cas_in_dly <= 2'b11;
		
		scl_in_clean  <= 1'b1 ;
		sda_in_clean  <= 1'b1 ;
		scl_in_clean_dly <= 2'b11;
		sda_in_clean_dly <= 2'b11;
		
		scl_cas_in_clean  <= 1'b1 ;
		sda_cas_in_clean  <= 1'b1 ;
	end
	else
	begin
		scl_in_clean_dly <= {scl_in_clean_dly[0] , scl_in_clean};
		sda_in_clean_dly <= {sda_in_clean_dly[0] , sda_in_clean};
		scl_in_dly <= {scl_in_dly[4:0],scl_in};
		sda_in_dly <= {sda_in_dly[4:0],sda_in};
		scl_cas_in_dly <= {scl_cas_in_dly[0],scl_cas_in};
		sda_cas_in_dly <= {sda_cas_in_dly[0],sda_cas_in};
		
		if (scl_in_dly[5:1] == 5'b11111)
			scl_in_clean <= 1'b1;                 //delay 5 cycle relative to scl_in
		else if (scl_in_dly[5:1] == 5'b00000)
			scl_in_clean <= 1'b0;
		
		if (sda_in_dly[5:1] == 5'b11111)
			sda_in_clean <= 1'b1;                 //delay 5 cycle relative to scl_in
		else if (sda_in_dly[5:1] == 5'b00000)
			sda_in_clean <= 1'b0;
			
			
		if ({scl_cas_in_dly,scl_cas_in} == 3'b111)
			scl_cas_in_clean <= 1'b1;                 //delay 5 cycle relative to scl_in
		else if ({scl_cas_in_dly,scl_cas_in} == 3'b000)
			scl_cas_in_clean <= 1'b0;

		if ({sda_cas_in_dly,sda_cas_in} == 3'b111)
			sda_cas_in_clean <= 1'b1;                 //delay 5 cycle relative to scl_in
		else if ({sda_cas_in_dly,sda_cas_in} == 3'b000)
			sda_cas_in_clean <= 1'b0;	
	end
end

assign start = (~sda_in_clean) & sda_in_clean_dly[0] & scl_in_clean ;
assign stop  = (~sda_in_clean_dly[0]) & sda_in_clean & scl_in_clean ;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		rcv_bit[7:0] <= 8'd0;
		bit_cnt[2:0] <= 3'd0;
		delay_cnt <= 8'd0;
		delay_cnt_en <= 1'b0; 
		opcode <= 1'b0 ;
		start_en <= 1'b0;
		start_next_bit <= 1'b0;
		rcv_ack <= 1'b0 ;
		word_addr <= 8'd0;
		word_addr_vld <= 1'b0;
	end
	else 
	begin
		start_next_bit <= 1'b0;
		if ((current_state == IDLE) & (start_en ==1'b0)) 
		begin
			delay_cnt <= 8'd0;
			delay_cnt_en <= 1'b0;
		end
		else if(scl_in_clean_dly == 2'b10)    
		begin
			delay_cnt <= 8'd0;
			delay_cnt_en <= 1'b1;  
		end
		else if (delay_cnt_en)
			if (delay_cnt != (I2C_SPEED_DIV+4)/8)  // falling edge delay 1/8 bit width
				delay_cnt <= delay_cnt + 1'b1;
			else
			begin
				start_next_bit <= 1'b1;
				delay_cnt_en <= 1'b0;
			end
		else
			start_next_bit <= 1'b0;
			
		if(current_state != next_state)
			bit_cnt <= 0;
		else if (start_next_bit)
			bit_cnt <= bit_cnt + 1'b1;
		
		if(scl_in_clean_dly == 2'b01)
		begin				
			case (bit_cnt)
				0:  rcv_bit[7]  <= sda_in_clean;
				1:	rcv_bit[6]  <= sda_in_clean;
				2:  rcv_bit[5]  <= sda_in_clean;
				3:	rcv_bit[4]  <= sda_in_clean;
				4:	rcv_bit[3]  <= sda_in_clean;
				5:	rcv_bit[2]  <= sda_in_clean;
				6:  rcv_bit[1]  <= sda_in_clean;
				7: 	rcv_bit[0]  <= sda_in_clean;
			endcase
			if ((current_state == DEV_ADDR_STATE) && (bit_cnt == 3'd7))
				opcode <= sda_in_clean ;
			if (current_state == WAIT_ACK)
				rcv_ack <= (!sda_in_clean) ;
		end
		
		if (start_next_bit == 1'b1)
		begin
			if((current_state == WORD_ADDR_STATE) && (bit_cnt ==7))
			begin
				word_addr <= rcv_bit ;
				word_addr_vld <= 1'b1;
			end
			else if((current_state == SEND_DATA) && (bit_cnt ==7))  // ready for next send
			begin
				word_addr <= word_addr + 1'b1;
				word_addr_vld <= 1'b1;
			end
			else if((current_state == SEND_ACK) && (before_state == RCV_DATA))  //ready for next write
			begin
				word_addr <= word_addr + 1'b1;
				word_addr_vld <= 1'b1;
			end
			else
				word_addr_vld <= 1'b0;
		end
		else
			word_addr_vld <= 1'b0;
		
		if(start == 1'b1)
			start_en <= 1'b1;
		else if ((stop == 1'b1) || (start_next_bit == 1'b1) || (time_out_en == 1'b1))
			start_en <= 1'b0;
	end
end

		
always@(posedge clk or negedge rst_n)
 begin
	if(!rst_n)
	begin
		current_state <= IDLE;
	end
	else
	begin
		if (time_out_en == 1)
			current_state <= IDLE;
		else
			current_state <= next_state ;
	end
end

always@(*)
begin
	case(current_state)
	IDLE:
	begin
		if (start_en & start_next_bit)
			next_state = DEV_ADDR_STATE;
		else
			next_state = IDLE;
	end
	DEV_ADDR_STATE :
		if (stop)
			next_state = IDLE;
		else if ((start_next_bit ==1) && (bit_cnt == 3'd7))
			//if  (((slave_addr_out >= SLAVE_ADDR_MIN) && (slave_addr_out <= SLAVE_ADDR_MAX)) || (slave_addr_out == SLAVE_ADDR_OTHER))  // dev address match
			if(slave_addr_out == slave_addr)
				next_state = SEND_ACK;
			else
				next_state = IDLE ;
		else			
			next_state = DEV_ADDR_STATE ;
	SEND_ACK :	
		if (stop == 1)                    // it may stop directly
			next_state = IDLE ;
		else if (start_en & start_next_bit)
			next_state = DEV_ADDR_STATE ;
		else if (start_next_bit == 1)
			if ((!rcv_cas_ack) & (CAS_MODE))
				next_state = IDLE;
			else if (opcode == 1'b0)        // write operation
				if (before_state == WORD_ADDR_STATE)
					next_state = RCV_DATA ;
				else if(before_state == DEV_ADDR_STATE)
					next_state = WORD_ADDR_STATE ;
				else
					next_state = RCV_DATA ;
			else                              //not  support continous reading
				next_state = SEND_DATA ;
		else
			next_state = SEND_ACK ;
	WORD_ADDR_STATE :         
		if (stop == 1)
			next_state = IDLE ;
		else if ((start_next_bit ==1) && (bit_cnt == 3'd7))
			next_state = SEND_ACK ;
		else
			next_state = WORD_ADDR_STATE;
	RCV_DATA :
		if (stop == 1)		  // it may stop 
			next_state = IDLE ;
		else if (start_en & start_next_bit)              // it may be repeat start
			next_state = DEV_ADDR_STATE;
		else if((start_next_bit == 1) && (bit_cnt == 3'd7))
			next_state = SEND_ACK ;
		else
			next_state = RCV_DATA ;                      // support continous write
	SEND_DATA :
		if (stop == 1)
			next_state = IDLE ;
		else if ((start_next_bit ==1) & (bit_cnt == 3'd7))   // 
			next_state = WAIT_ACK;
		else			
			next_state = SEND_DATA ;
	WAIT_ACK :
		if (stop == 1)
			next_state = IDLE ;
		else if(start_next_bit)
		begin
			if(rcv_ack)
				next_state = SEND_DATA ;          // continous reading
			else
				next_state = IDLE ;
		end		
		else
			next_state = WAIT_ACK;
	default:
		next_state = IDLE;
	endcase 
end

//  generate  sda_out 
always@(posedge clk or negedge rst_n)
 begin
	if(!rst_n)
	begin
		sda_out_reg <= 1'b1 ;
		start_next_bit_1d <= 1'b0;
		wr_data <= 8'd0 ;
		wr_data_vld <= 1'b0 ;
		slave_addr_out <=7'd0;
		slave_addr_vld <= 1'b0;
		before_state <= 4'd0;
		is_slave_send <= 1'b0;
	end
	else
	begin
		start_next_bit_1d <= start_next_bit ;
		if (current_state != next_state)
			before_state <= current_state ;
		
		case (current_state)
			IDLE:
			begin
				is_slave_send <= 1'b0;
				wr_data_vld <= 1'b0 ;
				slave_addr_vld <= 1'b0;
				sda_out_reg <= 1'b1;
			end
			DEV_ADDR_STATE :
			begin
				wr_data_vld <= 1'b0 ;
				sda_out_reg <= 1'b1;
				if ((start_next_bit== 1'b1) &&(bit_cnt ==6)) 
				begin
					slave_addr_out <= rcv_bit[7:1] ;
					slave_addr_vld <= start_next_bit ;
				end
				else
					slave_addr_vld <= 1'b0;
			end			
			SEND_ACK:
			begin
				wr_data_vld <= 1'b0 ;
				if (start_next_bit_1d)
				begin
					is_slave_send <= 1'b1;
					sda_out_reg <= 1'b0;
				end
				else if (start_next_bit == 1'b1) 
				begin
					if ((!rcv_cas_ack) & (CAS_MODE))
						is_slave_send <= 1'b0;
					else if (next_state != SEND_DATA)
						is_slave_send <= 1'b0;
					sda_out_reg <= 1'b1;
				end
			end
			SEND_DATA :
			begin
				wr_data_vld <= 1'b0 ;
				if (start_next_bit_1d)
				begin
					is_slave_send <= 1'b1;
					case (bit_cnt)
					0:  sda_out_reg     <= rd_data[7];
					1:	sda_out_reg     <= rd_data[6];
					2:  sda_out_reg     <= rd_data[5];
					3:	sda_out_reg     <= rd_data[4];
					4:	sda_out_reg     <= rd_data[3];
					5:	sda_out_reg     <= rd_data[2];
					6:  sda_out_reg     <= rd_data[1];
					7: 	sda_out_reg     <= rd_data[0];
					endcase
				end
				else if((start_next_bit == 1'b1) && (bit_cnt ==7))
				begin
					sda_out_reg <= 1'b1;
					is_slave_send <= 1'b0;
				end
			end
			WORD_ADDR_STATE:
			begin	
				wr_data_vld <= 1'b0 ;
				sda_out_reg <= 1'b1;
			end
			RCV_DATA:
			begin	
				sda_out_reg <= 1'b1;
				if ((start_next_bit== 1'b1) &&(bit_cnt ==7)) 
				begin
					wr_data <= rcv_bit ;
					wr_data_vld <= start_next_bit ;
				end
				else
					wr_data_vld <= 1'b0;
			end
			WAIT_ACK:
			begin
				wr_data_vld <= 1'b0 ;
				sda_out_reg <= 1'b1;
			end
			default:
			begin
				wr_data_vld <= 1'b0 ;
				slave_addr_vld <= 1'b0;
				is_slave_send <= 1'b0;
				sda_out_reg <= 1'b1 ;
			end
		endcase
	end			
		
end


always@(posedge clk or negedge rst_n)
 begin
	if(!rst_n)
	begin
		timeout_cnt <= 5'd0;
		timeout_cnt_en <= 1'b0;
		time_out_en <= 1'b0;
	end
	else
		if (start)
		begin
			timeout_cnt_en <= 1'b1;
			timeout_cnt <= 5'd0;
		end
		else if (timeout_cnt_en )
		begin	
			if (stop)
			begin
				timeout_cnt_en <= 1'b0;
				time_out_en <= 1'b0;
				timeout_cnt <= 5'd0;
			end
			else if (int_1ms_en)
			begin
				if (timeout_cnt == 5'd31)           //31ms timeout
				begin
					time_out_en <= 1'b1;
					timeout_cnt <= 5'd0;
					timeout_cnt_en <= 1'b0;
				end
				else
				begin
					timeout_cnt <= timeout_cnt + 1'b1;
					time_out_en <= 1'b0;
				end
			end
		end
		else
		begin
			timeout_cnt <= 5'd0;
			time_out_en <= 1'b0;
		end
end

//////////////////////////////for cascade mux ///////////////////////////

//////////////detect stretching, add ack check,only ack generate the second stretching//////////////////////

assign start_send_wait =((start_next_bit_1d | (start_next_bit)) && (current_state == SEND_ACK))  & (CAS_MODE ==1'b1) ;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		start_stretch_det <= 1'b0;

		stretch_cnt <= 9'd0;
		stretch_cnt_en <=1'b0;
		start_stretch_det_dly <= 2'b00;
		
		scl_cas_out_en <= 1'b1;
		stretch_en <= 1'b0; 
		det_delay_cnt <= 5'd0;
	end
	else 
	begin

		if (start_send_wait)       //  rising edge
		begin
			stretch_cnt_en <= 1'b1;
			stretch_cnt <= 9'd0;
			start_stretch_det <= 1'b0;
		end
		else if (stretch_cnt_en)
		begin
			if (stretch_cnt == (I2C_SPEED_DIV*3+4)/8)    //3/8 bit width
			begin
				stretch_cnt_en <= 1'b0;
				start_stretch_det <= 1'b1;
			end
			else
			begin
				start_stretch_det <= 1'b0;
				stretch_cnt <= stretch_cnt + 1'b1;
			end
		end
		else
			start_stretch_det <= 1'b0;
		
		if ((start_stretch_det == 1'b1)) //
		begin
			scl_cas_out_en <= 1'b0;
		end
		else if(!scl_cas_out_en)
		begin
			if((scl_cas_in_clean & scl_in_clean) | (time_out_en))     //  delay , wait master response to high
			begin
				scl_cas_out_en <= 1'b1;
			end
		end
			
		if (start_send_wait)       //  rising edge
			stretch_en <= 1'b1;
		else if (((scl_cas_out_en == 1'b0) && (scl_cas_in_clean== 1'b1)) || (time_out_en))
			stretch_en <= 1'b0;
	end
end



always@(posedge clk or negedge rst_n)
 begin
	if(!rst_n)
	begin
		mux_clk_en  <= 1'b0;
		mux_data_en <= 1'b0;
		stretch_en_1d <= 1'b0;
		rcv_cas_ack <= 1'b0;
		stop_1d <= 1'b0;
	end
	else
	begin
		stretch_en_1d <= stretch_en ;
		stop_1d <= stop ;
		////////////////  let ack clock pass ///////////////
		if ((stop_1d == 1'b1) | (time_out_en))
			mux_clk_en <= 1'b0;
		else if ((stretch_en_1d == 1'b1) && (stretch_en == 1'b0)  && (current_state != SEND_ACK) && (CAS_MODE==1'b1)) //falling
			mux_clk_en <= 1'b1;
		
		if ((stop_1d == 1'b1) | (time_out_en))
			mux_data_en <= 1'b0;
		else if((slave_addr_vld) && ((slave_addr_out == 7'h38)|| (slave_addr_out == 7'h5C)) && (CAS_MODE ==1'b1)) 
			mux_data_en <= 1'b1;
		
		
		if ((current_state == SEND_ACK) && (scl_in_clean_dly == 2'b01))      //get ack or nack
			rcv_cas_ack <= (!sda_cas_in_clean) ;
		
	end
end
assign sda_out = sda_out_reg ;

endmodule

	
		



	
	
	
	