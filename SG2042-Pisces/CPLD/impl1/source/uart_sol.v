module uart_sol
(
input wire sys_uart_txd3,
output reg sys_uart_rxd3,

input wire uart0_tx_a,
output reg uart0_rx_a,

input wire uart1_tx_a,
output reg uart1_rx_a,

input wire uart0_tx_b,
output reg uart0_rx_b,

input wire uart1_tx_b,
output reg uart1_rx_b,


input wire BMC_GPIO24,
input wire BMC_GPIO25,

input wire reset
);
wire[1:0] sol_select;
assign sol_select = {BMC_GPIO24,BMC_GPIO25};

always@(*)
begin
	if(reset==1'b0)
		begin
			uart0_rx_a = 1'bZ;
			uart1_rx_a = 1'bZ;			
			uart0_rx_b = 1'bz;		
			uart1_rx_b = 1'bz;	
			sys_uart_rxd3 = 1'bz;
		end
	else
		case(sol_select)
			2'b00:
				begin
					uart0_rx_a=sys_uart_txd3;
					sys_uart_rxd3=uart0_tx_a;			
					uart1_rx_a = 1'bz;		
					uart0_rx_b = 1'bz;			
					uart1_rx_b = 1'bz;		
				end
			2'b01:
				begin
					uart0_rx_a=1'bz;			
					uart1_rx_a = sys_uart_txd3;
					sys_uart_rxd3 = uart1_tx_a;			
					uart0_rx_b = 1'bz;			
					uart1_rx_b = 1'bz;		
				end			
			2'b10:
				begin
					uart0_rx_a=1'bz;			
					uart1_rx_a = 1'bz;			
					uart0_rx_b = sys_uart_txd3;
					sys_uart_rxd3 = uart0_tx_b;		
					uart1_rx_b = 1'bz;			
				end
			2'b11:
				begin
					uart0_rx_a=1'bz;		
					uart1_rx_a = 1'bz;		
					uart0_rx_b = 1'bz;	
					uart1_rx_b = sys_uart_txd3;
					sys_uart_rxd3 = uart1_tx_b;				
				end
				
			default:
				begin
					uart0_rx_a = 1'bz;
					uart1_rx_a = 1'bz;			
					uart0_rx_b = 1'bz;		
					uart1_rx_b = 1'bz;	
					sys_uart_rxd3 = 1'bz;	
				end
		endcase
end

endmodule