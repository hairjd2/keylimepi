module ctrl_logic #(
parameter DATA_WIDTH = 128
)(
    input clk,
    input rst_n,
    
    // UART RX data
    input [7:0] rx_data,
    input rx_valid,
    output logic rx_ready,
    
    // UART TX data
    output logic [7:0] tx_data,
    output logic tx_valid,
    input tx_ready,

    // Memory interface
    output logic [0:0] we,
    output logic [11:0] addr,
    output logic [511:0] dout,
    input [511:0] din,
    output enb
);
    localparam DONE_RESP = 32'h444f4e45;

    // state machine
    enum {init, wait_client, init_resp, wait_pw, check_pw, output_resp, idle, get_len, wait_for_len, get_data, wait_for_data, tx_mem_data, set_len, load_len, set_data, load_data} curr_state;

    logic [5:0] byte_counter;
    logic [5:0] byte_counter_d;

    logic [511:0] write_reg;

    logic [31:0] resp_code;

    logic [11:0] addr_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            curr_state <= idle;
            byte_counter <= '0;
            write_reg <= 0;
            resp_code <= 0;
            addr_reg <= 0;
        end else begin
            // Avoiding inferring latches
            curr_state <= curr_state;
            byte_counter <= byte_counter;
            tx_data <= '0;
            tx_valid <= 0;
            rx_ready <= 1;
            write_reg <= write_reg;
            resp_code <= resp_code;
            addr_reg <= addr_reg;

            case (curr_state)
                init: begin
                    
                end
                idle: begin // Sits here until the FPGA receives a valid command
                    tx_valid <= 0;
                    we <= 0;
                    addr_reg <= 0;

                    // Looking for the MSb and LSb to be a 1 (meaning a pw read)
                    if(rx_valid) begin
                        addr_reg[11:10] <= rx_data[3:2];
                        addr_reg[1:0] <= rx_data[1:0];

                        if(rx_data[7]) begin // The read bit is asserted
                            curr_state <= get_len;
                        end else // Write bit is asserted (active-low)
                            curr_state <= set_len;
                    end else begin
                        curr_state <= idle;
                    end
                    byte_counter <= 0;
                end
                get_len: begin
                    tx_valid <= 0;
                    byte_counter <= 6'h00;
                    if(rx_valid) begin
                        addr <= {addr_reg[11:10], rx_data, 2'b01};
                        addr_reg[9:2] <= rx_data;
                        curr_state <= wait_for_len;
                    end
                end
                wait_for_len: begin
                    byte_counter <= byte_counter + 1;
                    if(byte_counter == 6'h01) begin
                        curr_state <= get_data;
                        case(addr_reg[1:0])
                            2'b00: tx_data <= din[487:480];
                            2'b01: tx_data <= din[495:488];
                            2'b10: tx_data <= din[503:496];
                            2'b11: tx_data <= din[511:504];
                        endcase
                        tx_valid <= 1;
                    end
                end
                // Retrieve data
                get_data: begin
                    tx_valid <= 0;
                    byte_counter <= 6'h00;
                    // data types: 0 and 1: domain name; 2: username; 3: password
                    addr <= addr_reg; // Forcing the address to next line since the count and other metadata is at 0th address
                    curr_state <= wait_for_data; // Wait for the ram to output data at address
                end
                // Wait two cycles for ram to output data
                wait_for_data: begin
                    byte_counter <= byte_counter + 1;
                    // After two cycles, can start outputting data at address set
                    if(byte_counter == 6'h01) begin 
                        curr_state <= tx_mem_data;
                        if(addr_reg[1:0] == 2'b01)
                            byte_counter <= 6'h3b;
                        else
                            byte_counter <= 6'h3f;
                    end
                end
                // Transmit data from ram
                tx_mem_data: begin
                    // Write every byte of the 64 bytes in ram to the buffer
                    byte_counter <= byte_counter - 1;
                    tx_data <= din[byte_counter*8 +: 8];
                    tx_valid <= 1;
                    resp_code <= DONE_RESP;
                    // TODO: Check that the fifo is ready to receive data
                    if(byte_counter == 6'h00) begin // After 64 bytes are written, return to idle
                        curr_state <= output_resp;
                        byte_counter <= 6'b000011;
                    end else
                        curr_state <= tx_mem_data;
                end
                set_len: begin
                    tx_valid <= 0;
                    if(rx_valid) begin
                        addr_reg[9:2] <= rx_data;
                        addr <= {addr[11:10], rx_data, 2'b01};
                        curr_state <= load_len;
                    end
                end
                load_len: begin
                    if(rx_valid) begin
                        case(addr_reg[1:0])
                            2'b00: dout[487:480] <= rx_data;
                            2'b01: dout[495:488] <= rx_data;
                            2'b10: dout[503:496] <= rx_data;
                            2'b11: dout[511:504] <= rx_data;
                        endcase
                        we <= 1;
                        curr_state <= set_data;
                    end
                end
                // Set data at given address
                set_data: begin
                    tx_valid <= 0;
                    if(addr_reg[1:0] == 2'b01)
                        byte_counter <= 6'h3a;
                    else
                        byte_counter <= 6'h3e;
                    if(rx_valid) begin
                        we <= 1;
                        // data types: 0 and 1: domain name; 2: username; 3: password
                        addr <= addr_reg; // Use address and offset (data type) given
                        curr_state <= load_data;
                        write_reg <= 0;
                        write_reg[511:504] <= rx_data;
                    end
                end
                // Write received data to RAM
                load_data: begin
                    if(rx_valid) begin
                        // For each valid piece of received data, write it to ram
                        write_reg[byte_counter*8 +: 8] <= rx_data;
                        byte_counter <= byte_counter - 1; 
                        if(byte_counter == 6'h00) begin // Once at 0, can transmit done to 
                            we <= 1;
                            dout[511:8] <= write_reg[511:8];
                            dout[7:0] <= rx_data; // TODO: There is prob a better way to do this, like making sure the ready goes low at this state so the data doesn't change
                            curr_state <= output_resp;
                            byte_counter <= 6'b000011;
                            resp_code <= DONE_RESP;
                        end else begin
                            we <= 0;
                            dout <= 511'hz;
                            curr_state <= load_data;
                        end
                    end
                end
                // Finished writing data to ram, output that it is done
                output_resp: begin
                    byte_counter <= byte_counter - 1;
                    we <= 0;
                    addr <= 0;
                    tx_valid <= 1;
                    tx_data <= resp_code[byte_counter*8 +: 8];

                    if(byte_counter == 0)
                        curr_state <= idle;
                    else
                        curr_state <= output_resp;
                end

                default: curr_state <= idle;
            endcase
        end
    end

endmodule
