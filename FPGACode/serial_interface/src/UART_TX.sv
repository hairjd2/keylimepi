module UART_TX
#(parameter CLKS_PER_BIT)
(
	input clk,
	input rst_n,
	input [7:0] tx_byte,
	input tx_valid,

	output tx_ready,
	output tx_uart,
	output tx_done
);

	enum {idle, start_bit, data_bits, stop_bit, cleanup} curr_state;
	int clk_counter;
	int bit_index;
	logic [7:0] curr_data;
	logic tx_done_q;
	logic tx_ready_q;
	logic tx_uart_q;

	assign tx_ready = tx_ready_q;
	assign tx_done = tx_done_q;
	assign tx_uart = tx_uart_q;

	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			clk_counter = '0;
			bit_index = '0;
			curr_data <= '0;
			tx_done_q <= '0;
			tx_ready_q <= '0;
			tx_uart_q <= 1'b1;
			curr_state <= idle;
		end else begin
		    clk_counter = clk_counter;
			bit_index = bit_index;
			curr_data <= curr_data;
			tx_done_q <= tx_done_q;
			tx_ready_q <= tx_ready_q;
			tx_uart_q <= tx_uart_q;
			curr_state <= curr_state;
			case(curr_state)
				idle: begin
					tx_ready_q <= 0;
					tx_uart_q <= 1;
					tx_done_q <= 0;
					clk_counter <= 0;
					bit_index <= 0;

					if(tx_valid) begin
						curr_data <= tx_byte;
						curr_state <= start_bit;
					end else begin
						curr_state <= idle;
					end
				end
				start_bit: begin
					tx_ready_q <= 1'b1;
					tx_uart_q <= 1'b0;
					if(clk_counter < CLKS_PER_BIT-1) begin
						clk_counter <= clk_counter + 1;
						curr_state <= start_bit;
					end else begin
						clk_counter <= 0;
						curr_state <= data_bits;
					end
				end
				data_bits: begin
					tx_uart_q <= curr_data[bit_index];

					if(clk_counter < CLKS_PER_BIT-1) begin
						clk_counter <= clk_counter + 1;
						curr_state <= data_bits;
					end else begin
						clk_counter <= 0;

						if(bit_index < 7) begin
							bit_index <= bit_index + 1;
							curr_state <= data_bits;
						end else begin
							bit_index <= '0;
							curr_state <= stop_bit;
						end
					end
				end
				stop_bit: begin
					tx_uart_q <= 1;

					if(clk_counter < CLKS_PER_BIT-1) begin
						clk_counter <= clk_counter + 1;
						curr_state <= stop_bit;
					end else begin
						tx_done_q <= 1;
						clk_counter <= '0;
						curr_state <= cleanup;
					end
				end
				cleanup: begin
					tx_ready_q <= 0;
					tx_done_q <= 0;
					curr_state <= idle;
				end
				default: begin
					curr_state <= idle;
				end
			endcase
		end
	end

endmodule