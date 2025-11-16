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

    // Memory interface // TODO: This will change once I can start testing with the actual flash chip
    output logic [0:0] we,
    output logic [11:0] addr,
    output logic [511:0] dout,
    input [511:0] din,
    output enb
);
    
    enum {init, valid_pw, bad_pw, idle, unk_cmd, stor_pw, op_res, get_pw, set_pw, tx_mem_data, wr_mem_data, wait_for_address, load_data} next_state, curr_state;
    enum {short_read, long_read} rd_cmd;
    enum {short_write, long_write} wr_cmd;

    logic [5:0] byte_counter;
    logic [5:0] byte_counter_d;

    logic [511:0] write_reg;
    logic [1:0] data_type;

    // assign we = 0; // TODO: Just testing reads right now
    // assign dout = 32'h61626364;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            curr_state <= idle;
            byte_counter <= '0;
            write_reg <= 0;
            data_type <= 0;
        end else begin
            curr_state <= curr_state;
            byte_counter <= byte_counter;
            tx_data <= '0;
            tx_valid <= 0;
            rx_ready <= 1;
            write_reg <= write_reg;
            data_type <= data_type;
            case (curr_state)
                idle: begin
                    tx_valid <= 0;
                    we <= 0;

                    // Looking for the MSb and LSb to be a 1 (meaning a pw read)
                    if(rx_valid == 1)
                        data_type <= rx_data[1:0];
                        if(rx_data[7] && rx_valid)
                            curr_state <= get_pw; // TODO: Change state name
                        else if(!rx_data[7] && rx_valid)
                            curr_state <= set_pw;
                    else
                        curr_state <= idle;
                    byte_counter <= 0;
                end
                get_pw: begin
                    tx_valid <= 0;
                    byte_counter <= 6'h00;
                    if(rx_valid) begin
                        addr <= {2'b00, rx_data, data_type};
                        curr_state <= wait_for_address;
                    end
                end
                wait_for_address: begin
                    byte_counter <= byte_counter + 1;
                    if(byte_counter == 6'h01) begin
                        curr_state <= tx_mem_data;
                        byte_counter <= 6'h00;
                    end
                end
                tx_mem_data: begin
                    byte_counter <= byte_counter + 1;
                    tx_data <= din[byte_counter*8 +: 8];
                    tx_valid <= 1;
                    if(byte_counter == 6'h3F)
                        curr_state <= idle;
                    else
                        curr_state <= tx_mem_data;
                end
                set_pw: begin
                    tx_valid <= 0;
                    byte_counter <= 6'h3F;
                    if(rx_valid) begin
                        we <= 1;
                        addr <= {2'b00, rx_data, data_type}; // TODO: Make logic to make this an offset
                        curr_state <= load_data;
                        write_reg <= 0;
                    end
                end
                load_data: begin
                    if(rx_valid) begin
                        write_reg[byte_counter*8 +: 8] <= rx_data;
                        byte_counter <= byte_counter - 1;
                        if(byte_counter == 6'h00) begin
                            we <= 1;
                            dout[511:8] <= write_reg[511:8];
                            dout[7:0] <= rx_data; // TODO: There is prob a better way to do this, like making sure the ready goes low at this state so the data doesn't change
                            curr_state <= wr_mem_data;
                        end else begin
                            we <= 0;
                            dout <= 511'hz;
                            curr_state <= load_data;
                        end
                    end
                end
                wr_mem_data: begin
                    // next_state <= wr_mem_data;
                    byte_counter <= byte_counter + 1;
                    we <= 0;
                    if(byte_counter == 6'b000000) begin
                        addr <= 0;
                        tx_data <= 8'h65; // output d
                        tx_valid <= 1;
                        curr_state <= wr_mem_data;
                    end else if(byte_counter == 6'b000001) begin
                        we <= 0;
                        tx_data <= 8'h6e; // output o
                        tx_valid <= 1;
                        curr_state <= wr_mem_data;
                    end else if(byte_counter == 6'b000010) begin
                        tx_data <= 8'h6f; // output n
                        tx_valid <= 1;
                        curr_state <= wr_mem_data;
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
