module UART_RX
#(parameter CLKS_PER_BIT)
(
    input clk,
	input rst_n,
	input rx_uart,

	output [7:0] rx_byte,
	output rx_valid
);
    enum {idle, start_bit, data_bits, stop_bit, cleanup} curr_state;
    logic rx_bit;
    logic rx_bit_q;

    int clk_counter;
    int bit_index;
    logic [7:0] curr_data;
    logic rx_valid_q;

    assign rx_byte = curr_data;
    assign rx_valid = rx_valid_q;

// Double flopping to avoid metastability issue
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rx_bit <= 0;
            rx_bit_q <= 0;
        end else begin
            rx_bit <= rx_uart;
            rx_bit_q <= rx_bit;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            clk_counter <= '0;
            bit_index <= '0;
            curr_data <= '0;
            curr_state <= idle;
            rx_valid_q <= 0;
        end else begin
            clk_counter <= clk_counter;
            bit_index <= bit_index;
            curr_data <= curr_data;
            curr_state <= curr_state;
            rx_valid_q <= rx_valid_q;
            case(curr_state)
                idle: begin
                    rx_valid_q <= 0;
                    clk_counter <= '0;
                    bit_index <= '0;

                    if(rx_bit_q == 0)
                        curr_state <= start_bit;
                    else
                        curr_state <= idle;
                end
                start_bit: begin
                    if(clk_counter == (CLKS_PER_BIT-1)/2) begin
                        if(rx_bit_q == 0) begin
                            clk_counter <= '0;
                            curr_state <= data_bits;
                        end else begin
                            curr_state <= idle;
                        end
                    end else begin
                        clk_counter <= clk_counter + 1;
                        curr_state <= start_bit;
                    end
                end
                data_bits: begin
                    if(clk_counter < CLKS_PER_BIT-1) begin
                        clk_counter <= clk_counter + 1;
                        curr_state <= data_bits;
                    end else begin
                        clk_counter <= '0;
                        curr_data[bit_index] <= rx_bit_q;

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
                    if(clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                        curr_state <= stop_bit;
                    end else begin
                        rx_valid_q <= 1;
                        clk_counter <= '0;
                        curr_state <= cleanup;
                    end
                end
                cleanup: begin
                    curr_state <= idle;
                    rx_valid_q <= 1;
                end
                default: curr_state <= idle;
            endcase
        end
    end
    
endmodule