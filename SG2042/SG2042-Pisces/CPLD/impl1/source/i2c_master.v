
module i2c_master
#(
	parameter	I2C_SPEED_DIV 	=	10'd250
)
(
	input			clk, 
	input   		rst_n, 

	input[7:0]		device_addr,         ///low bit  R/W bit
	input[7:0]		word_addr,
	input[7:0]		data_wr_in,
	input           start,
	input           start_again,
	input           scl_in ,    
	input           sda_in ,
	input           int_1ms_en,
	output reg[7:0] rd_data,
	output reg		rd_data_vld,
	output 	reg	 	scl_out = 1'b1,
	output  reg     sda_out = 1'b1,
	output  reg     scl_out_en,
	output  reg     sda_out_en,
	output          i2c_busy
);

reg[3:0]  next_state;
reg[3:0]   current_state;  
reg[3:0]   before_state ;
reg[9:0]   state_cnt;
reg[2:0]   bit_cnt;
reg  	   scl_rising ;
reg        scl_falling ;
reg        start_next_bit ;
reg        start_repeat;

reg        rcv_ack ;
reg[5:0]   scl_in_dly  = 6'b111111;
reg[5:0]   sda_in_dly  = 6'b111111;
reg        start_next_bit_1d ;
reg        scl_in_clean = 1'b1 ;
reg[1:0]   scl_in_clean_dly = 2'b11;
reg        sda_in_clean = 1'b1 ;

reg        sda_bit_out ;
reg[7:0]   bit_mux ;   
reg        opcode ;   
reg        start_stretch_en ;
reg        start_stretch_det ;
reg[3:0]   det_delay_cnt ;
reg        scl_cnt_en ;

reg[4:0]  	timeout_cnt ;
reg      	timeout_cnt_en ;
reg 		time_out_en ;
reg         start_again_en  ;
localparam  IDLE              =  4'd0,
		   SEND_START        =  4'd1,
		   DEV_ADDR_STATE    =  4'd2,
		   WAIT_ACK          =  4'd3,
		   WORD_ADDR_STATE   =  4'd4,
		   SEND_ACK          =  4'd5,
		   SEND_DATA         =  4'd6,
		   REPEAT_START      =  4'd7,
		   READ_DATA         =  4'd8,
		   SEND_STOP         =  4'd9,
		   SEND_NACK         =  4'd10;

/* remove small spur */
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		scl_in_dly <= 6'b111111;
		sda_in_dly <= 6'b111111;
		scl_in_clean  <= 1'b1 ;
		sda_in_clean  <= 1'b1 ;
	end
	else
	begin
		scl_in_dly <= {scl_in_dly[4:0],scl_in};
		sda_in_dly <= {sda_in_dly[4:0],sda_in};
		if (scl_in_dly[5:1] == 5'b11111)
			scl_in_clean <= 1'b1;                 //delay 7 cycle relative to scl_in
		else if (scl_in_dly[5:1] == 5'b00000)
			scl_in_clean <= 1'b0;
		
		if (sda_in_dly[5:1] == 5'b11111)
			sda_in_clean <= 1'b1;                 //delay 7 cycle relative to scl_in
		else if (sda_in_dly[5:1] == 5'b00000)
			sda_in_clean <= 1'b0;
	end
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		state_cnt <= 10'd0; 
		bit_cnt <= 3'd7;
		before_state <= IDLE;
	end
	else
		if (current_state == IDLE)
		begin
			state_cnt <= 10'd0;
			bit_cnt <= 3'd7;
		end
		else
		begin
			if (state_cnt == (I2C_SPEED_DIV -1))
			begin
				state_cnt <= 10'd0;
				if (next_state != current_state)
				begin
					bit_cnt <= 3'd7;
					before_state <= current_state ;
				end
				else
					bit_cnt <= bit_cnt - 1'b1;
			end
			else if (scl_cnt_en == 1'b1)
				state_cnt <= state_cnt +1'b1;
		end
end


always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		start_stretch_det <= 1'b0;
		scl_rising <= 1'b0;
		scl_falling <= 1'b0;
		start_next_bit <= 1'b0;
		start_repeat <= 1'b0;
		opcode <= 1'b0;
		start_again_en <= 1'b0;
	end
	else
	begin
		start_next_bit <= 1'b0;
		scl_falling <= 1'b0;
		scl_rising <= 1'b0;
		start_repeat <= 1'b0 ;
		start_stretch_det <= 1'b0;
		
		if (current_state == READ_DATA)
		begin
			if (start_again)
				start_again_en <= 1'b1;
		end
		else
			start_again_en <= 1'b0;
		
		if (state_cnt == (I2C_SPEED_DIV/4-5))
			start_stretch_det <= 1'b1;
		else if (state_cnt == (I2C_SPEED_DIV/4-1))
			scl_rising <= 1'b1;
		else if (state_cnt == (I2C_SPEED_DIV/2-1))
			start_repeat <= 1'b1;
		else if (state_cnt == (I2C_SPEED_DIV*3/4-1))
			scl_falling <= 1'b1;
		else if (state_cnt == (I2C_SPEED_DIV-2))
			start_next_bit <= 1'b1;
			
		if (current_state == IDLE)
			opcode <= 1'b0;
		else if (current_state == WORD_ADDR_STATE)   
			opcode <= device_addr[0] ;
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
		if (start)
			next_state = SEND_START;
		else
			next_state = IDLE;
	end
	SEND_START:
		if(start_next_bit == 1)
			next_state = DEV_ADDR_STATE ;
		else
			next_state = SEND_START;
	DEV_ADDR_STATE :
		if ((start_next_bit ==1) & (bit_cnt == 3'd0))
			next_state = WAIT_ACK;
		else			
			next_state = DEV_ADDR_STATE ;
	WAIT_ACK :		
		if (start_next_bit ==1) 
			if (rcv_ack == 1)
				if (before_state == DEV_ADDR_STATE)
					if (opcode ==1)                   // reading 
						next_state = READ_DATA ;
					else					
						next_state = WORD_ADDR_STATE ;
				else if (before_state == WORD_ADDR_STATE)
					if (opcode ==1)  //reading operation
						next_state = REPEAT_START ;
					else                                 
						next_state = SEND_DATA ;
				else
					next_state = SEND_STOP;           //not support continous write
			else
				next_state = SEND_STOP ;
		else
			next_state = WAIT_ACK ;
	WORD_ADDR_STATE :
		if ((start_next_bit ==1) & (bit_cnt == 3'd0))
			next_state = WAIT_ACK;
		else			
			next_state = WORD_ADDR_STATE ;
	SEND_DATA :
		if ((start_next_bit ==1) & (bit_cnt == 3'd0))
			next_state = WAIT_ACK;
		else			
			next_state = SEND_DATA ;
	SEND_STOP:
		if (start_next_bit ==1)
			next_state = IDLE;
		else			
			next_state = SEND_STOP ;
	
	REPEAT_START :
		if (start_next_bit ==1)
			next_state = DEV_ADDR_STATE;
		else			
			next_state = REPEAT_START;
	READ_DATA:
		if ((start_next_bit ==1)& (bit_cnt == 3'd0))    //  not support continous reading
		begin
			if (start_again_en)
				next_state = SEND_ACK ;
			else
				next_state = SEND_NACK ;
		end
		else
			next_state = READ_DATA ;
	SEND_NACK :
		if (start_next_bit ==1)
			next_state = SEND_STOP;
		else			
			next_state = SEND_NACK ;
	SEND_ACK :
		if (start_next_bit ==1)
			next_state = READ_DATA;
		else			
			next_state = SEND_ACK ;
	default:
		next_state = IDLE;
	endcase 
end

//  generate  sclk 
always@(posedge clk or negedge rst_n)
 begin
	if(!rst_n)
	begin
		scl_out <= 1'b1;
		sda_out <= 1'b1 ;
		start_next_bit_1d <= 1'b0;
		scl_in_clean_dly <= 2'b11;
		rcv_ack <= 1'b0;
		rd_data <= 8'd0 ;
		rd_data_vld <= 1'b0 ;
	end
	else
	begin
		start_next_bit_1d <= start_next_bit ;
		scl_in_clean_dly <= {scl_in_clean_dly[0] ,scl_in_clean};
		case (current_state)
			SEND_START:
				if (scl_rising)
					sda_out <= 1'b0;
				else if (scl_falling)
					scl_out <= 1'b0;
			DEV_ADDR_STATE:
			begin
				if (start_next_bit_1d)
					sda_out <= sda_bit_out ;
				if (scl_rising)
					scl_out <= 1'b1;
				else if (scl_falling)
					scl_out <= 1'b0;
			end
			WAIT_ACK:
			begin
				if (start_next_bit_1d) 
					sda_out <= 1'b1;
				if(scl_rising)
					scl_out <= 1'b1;
				else if (scl_falling)
					scl_out <= 1'b0;
				if(scl_in_clean_dly == 2'b01)    //rising edge
					rcv_ack <= !sda_in_clean ;
			end
			WORD_ADDR_STATE:
			begin
				if (start_next_bit_1d)
					sda_out <= sda_bit_out;
				if(scl_rising)
					scl_out <= 1'b1;
				else if (scl_falling)
					scl_out <= 1'b0;
			end
			SEND_DATA :
			begin
				if (start_next_bit_1d)
					sda_out <= sda_bit_out;
				if(scl_rising)
					scl_out <= 1'b1;
				else if (scl_falling)
					scl_out <= 1'b0;
			end
			SEND_STOP :
				if (start_next_bit_1d)
					sda_out <= 1'b0;
				else if(scl_rising)
					scl_out <= 1'b1;
				else if(scl_falling)
					sda_out <= 1'b1;
					
			REPEAT_START:
				if (start_next_bit_1d)
					sda_out <= 1'b1;
				else if (scl_rising)
					scl_out <= 1'b1;
				else if (start_repeat)
					sda_out <= 1'b0;
				else if (scl_falling)
					scl_out <= 1'b0;
			READ_DATA:
			begin
				if (scl_rising)
					scl_out <= 1'b1;
				else if(scl_falling)
					scl_out <= 1'b0;
				
				if(scl_in_clean_dly == 2'b01)    //rising edge
				begin
					case (bit_cnt)
					7:  rd_data[7] <= sda_in_clean ;
					6:	rd_data[6] <= sda_in_clean ;
					5:  rd_data[5] <= sda_in_clean ;
					4:	rd_data[4] <= sda_in_clean ;
					3:	rd_data[3] <= sda_in_clean ;
					2:	rd_data[2] <= sda_in_clean ;
					1:  rd_data[1] <= sda_in_clean ;
					0: 	rd_data[0] <= sda_in_clean ;
					endcase
					if (bit_cnt == 3'd0)
						rd_data_vld <= 1'b1;
					else
						rd_data_vld <= 1'b0;
				end
				else
					rd_data_vld <= 1'b0;
			end
			SEND_NACK:
				if (start_next_bit_1d)
					sda_out <= 1'b1;
				else if (scl_rising)
					scl_out <= 1'b1;
				else if(scl_falling)
					scl_out <= 1'b0;
			SEND_ACK:
				if (start_next_bit_1d)
					sda_out <= 1'b0;
				else if (scl_rising)
					scl_out <= 1'b1;
				else if(scl_falling)
					scl_out <= 1'b0;
			default:
			begin
				sda_out <= 1'b1;
				scl_out <= 1'b1;
			end
		endcase
	end			
		
end

always@(*)
begin
	if(current_state == DEV_ADDR_STATE)
		bit_mux = {device_addr[7:1] ,opcode} ;
	else if(current_state == WORD_ADDR_STATE)
		bit_mux = word_addr ;
	else 
		bit_mux = data_wr_in ;

	case (bit_cnt)
		7:  sda_bit_out = bit_mux[7];
		6:	sda_bit_out = bit_mux[6];
		5:  sda_bit_out = bit_mux[5];
		4:	sda_bit_out = bit_mux[4];
		3:	sda_bit_out = bit_mux[3];
		2:	sda_bit_out	= bit_mux[2];
		1:  sda_bit_out = bit_mux[1];
		0: 	sda_bit_out = bit_mux[0];
	endcase
end

//detect stretching   before and after ACK

//  generate  sclk 
always@(posedge clk or negedge rst_n)
 begin
	if(!rst_n)
	begin
		scl_out_en <= 1'b1;
		scl_cnt_en <= 1'b1;
		sda_out_en <= 1'b1;
		start_stretch_en <= 1'b0;
		det_delay_cnt <= 4'd0;
	end
	else
	begin
		if ((current_state == WAIT_ACK) && (start_next_bit | start_next_bit_1d))
			start_stretch_en <= 1'b1;
		else if ((start_stretch_en & start_stretch_det) || (current_state == IDLE))
			start_stretch_en <= 1'b0;
			
		
		if ((start_stretch_en & start_stretch_det) && (current_state != IDLE))
		begin
			scl_out_en <= 1'b0;
			scl_cnt_en <= 1'b0;
			det_delay_cnt <= 4'd0;
		end
		else if (!scl_out_en)
		begin
			if(current_state == IDLE)
			begin
				scl_out_en <= 1'b1;
				scl_cnt_en <= 1'b1;
			end
			else if(scl_in_clean)     //  delay 15cycles, wait master response
			begin
				scl_cnt_en <= 1'b1;
				if (det_delay_cnt == 15)
					scl_out_en <= 1'b1;
				else
					det_delay_cnt <= det_delay_cnt + 1'b1;
			end
		end
			
		if ((current_state == WAIT_ACK) && (start_next_bit_1d))
			sda_out_en <= 1'b0;
		else if ((current_state == WAIT_ACK) && (start_next_bit) && (next_state !=READ_DATA))
			sda_out_en <= 1'b1;
		else if ((current_state == READ_DATA) && (start_next_bit_1d))
			sda_out_en <= 1'b0;
		else if((current_state == READ_DATA) && (start_next_bit) && (bit_cnt == 3'd0))
			sda_out_en <= 1'b1;
		else if(current_state == IDLE)
			sda_out_en <= 1'b1;
	end
end

///////////////////////////time out protect
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
			time_out_en <= 1'b0;
		end
		else if (timeout_cnt_en )
		begin	
			if (current_state == IDLE)
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

assign  i2c_busy = timeout_cnt_en ;

endmodule

	
		



	
	
	
	