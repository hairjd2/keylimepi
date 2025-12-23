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
    // state machine
    enum {init, valid_pw, bad_pw, idle, get_data, set_data, tx_mem_data, output_done, wait_for_address, load_data, set_count, get_count} next_state, curr_state;

    logic [5:0] byte_counter;
    logic [5:0] byte_counter_d;

    logic [511:0] write_reg;
    logic [1:0] data_type;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            curr_state <= idle;
            byte_counter <= '0;
            write_reg <= 0;
            data_type <= 0;
        end else begin
            // Avoiding inferring latches
            curr_state <= curr_state;
            byte_counter <= byte_counter;
            tx_data <= '0;
            tx_valid <= 0;
            rx_ready <= 1;
            write_reg <= write_reg;
            data_type <= data_type;

            case (curr_state)
                idle: begin // Sits here until the FPGA receives a valid command
                    tx_valid <= 0;
                    we <= 0;

                    // Looking for the MSb and LSb to be a 1 (meaning a pw read)
                    if(rx_valid == 1)
                        data_type <= rx_data[1:0];
                        if(rx_data[7] && rx_valid) // The read bit is asserted
                            if(rx_data[6:0] == 7'h7F) // Indicates a read of the count of passwords
                                curr_state <= get_count;
                            else
                                curr_state <= get_data; // Otherwise retrieving value in memory
                        else if(!rx_data[7] && rx_valid) // Write bit is asserted (active-low)
                            if(rx_data[6:0] == 7'h7F) // Indicates an update of the number of passwords
                                curr_state <= set_count;
                            else
                                curr_state <= set_data; // Otherwise updating data in memory
                    else
                        curr_state <= idle;
                    byte_counter <= 0;
                end
                // Retrieve password count
                get_count: begin
                    tx_valid <= 0;
                    byte_counter <= 6'h00;
                    if(rx_valid) begin
                        addr <= 12'h000; // Hardcode the address to all 0's, will store more metadata here in the future
                        curr_state <= wait_for_address; // Wait for the ram to output data at address
                        // curr_state <= tx_mem_data;
                    end
                end
                // Retrieve data
                get_data: begin
                    tx_valid <= 0;
                    byte_counter <= 6'h00;
                    if(rx_valid) begin
                        // data types: 0 and 1: domain name; 2: username; 3: password
                        addr <= {2'b00, rx_data+1, data_type}; // Forcing the address to next line since the count and other metadata is at 0th address
                        curr_state <= wait_for_address; // Wait for the ram to output data at address
                    end
                end
                // Wait two cycles for ram to output data
                wait_for_address: begin
                    byte_counter <= byte_counter + 1;
                    // After two cycles, can start outputting data at address set
                    if(byte_counter == 6'h01) begin 
                        curr_state <= tx_mem_data;
                        byte_counter <= 6'h00;
                    end
                end
                // Transmit data from ram
                tx_mem_data: begin
                    // Write every byte of the 64 bytes in ram to the buffer
                    byte_counter <= byte_counter + 1;
                    tx_data <= din[byte_counter*8 +: 8];
                    tx_valid <= 1;
                    // TODO: Check that the fifo is ready to receive data
                    if(byte_counter == 6'h3F) // After 64 bytes are written, return to idle
                        curr_state <= idle;
                    else
                        curr_state <= tx_mem_data;
                end
                // Set the password count
                set_count: begin
                    tx_valid <= 0;
                    byte_counter <= 6'h3F;
                    if(rx_valid) begin
                        we <= 1;
                        addr <= 12'h000;
                        curr_state <= load_data;
                        write_reg <= 0;
                    end
                end
                // Set data at given address
                set_data: begin
                    tx_valid <= 0;
                    byte_counter <= 6'h3F;
                    if(rx_valid) begin
                        we <= 1;
                        // data types: 0 and 1: domain name; 2: username; 3: password
                        addr <= {2'b00, rx_data+1, data_type}; // Use address and offset (data type) given
                        curr_state <= load_data;
                        write_reg <= 0;
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
                            curr_state <= output_done;
                        end else begin
                            we <= 0;
                            dout <= 511'hz;
                            curr_state <= load_data;
                        end
                    end
                end
                // Finished writing data to ram, output that it is done
                output_done: begin
                    byte_counter <= byte_counter + 1;
                    we <= 0;
                    if(byte_counter == 6'b000000) begin
                        addr <= 0;
                        tx_data <= 8'h65; // output d
                        tx_valid <= 1;
                        curr_state <= output_done;
                    end else if(byte_counter == 6'b000001) begin
                        we <= 0;
                        tx_data <= 8'h6e; // output o
                        tx_valid <= 1;
                        curr_state <= output_done;
                    end else if(byte_counter == 6'b000010) begin
                        tx_data <= 8'h6f; // output n
                        tx_valid <= 1;
                        curr_state <= output_done;
                    end else if(byte_counter == 6'b000011) begin
                        tx_data <= 8'h44; // output e
                        tx_valid <= 1;
                        curr_state <= idle;
                    end
                end

                default: curr_state <= idle;
            endcase
        end
    end

endmodule
