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
    
    enum {init, valid_pw, bad_pw, idle, unk_cmd, stor_pw, op_res, get_pw, set_pw, tx_mem_data, wr_mem_data} next_state, curr_state;
    enum {short_read, long_read} rd_cmd;
    enum {short_write, long_write} wr_cmd;

    logic [5:0] byte_counter;
    logic [5:0] byte_counter_d;

    // assign we = 0; // TODO: Just testing reads right now
    // assign dout = 32'h61626364;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            curr_state <= idle;
            byte_counter <= '0;
        end else begin
            curr_state <= curr_state;
            byte_counter <= byte_counter;
            tx_data <= '0;
            tx_valid <= 0;
            rx_ready <= 1;
            case (curr_state)
                idle: begin
                    tx_valid <= 0;
                    we <= 0;

                    // Looking for the MSb and LSb to be a 1 (meaning a pw read)
                    if(rx_valid)
                        if(rx_data[7] && rx_data[0])
                            curr_state <= get_pw; // TODO: Testing for now
                        else if(!rx_data[7] && rx_data[0])
                            curr_state <= set_pw;
                    else
                        curr_state <= idle;
                    byte_counter <= 0;
                end
                get_pw: begin
                    tx_valid <= 0;
                    byte_counter <= 0;
                    if(rx_valid) begin
                        addr[7:0] <= rx_data;
                        curr_state <= tx_mem_data;
                    end
                end
                set_pw: begin
                    tx_valid <= 0;
                    byte_counter <= 0;
                    if(rx_valid) begin
                        we <= 1;
                        addr[7:0] <= rx_data; // TODO: Make logic to make this an offset
                        curr_state <= wr_mem_data;
                        if(rx_data == 0)
                            dout <= 512'h4675636b;
                        else
                            dout <= 512'h59656574;
                    end
                end
                wr_mem_data: begin
                    next_state <= wr_mem_data;
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
                tx_mem_data: begin
                    byte_counter <= byte_counter + 1;
                    tx_data <= din[byte_counter*8 +: 8];
                    tx_valid <= 1;
                    if(byte_counter == 6'h3F)
                        curr_state <= idle;
                    else
                        curr_state <= tx_mem_data;
                end
                default: curr_state <= idle;
            endcase
        end
    end

    // always_comb begin : state_machine
    //     byte_counter_d = byte_counter;
    //     rx_ready = '1;
    //     tx_data = '0;
    //     tx_valid = '0;
    //     case (curr_state)
    //         init: next_state = idle;
    //         // Delay for how many cycles needed to get things sent to reg file
    //         valid_pw: next_state = init;
    //         // Send request for master pw (?)
    //         // Make sure sent master password matches the one given
    //         bad_pw: next_state = init;
    //         // If the password does not match, send error message saying that
    //         // Could have a counter that waits for a certain amount of time if too
    //         // mny wrong guesses.
    //         idle: begin
    //         if(rx_data == 8'h61 && rx_valid) // Looking for a
    //             next_state = get_pw; // TODO: Testing for now
    //         else
    //             next_state = idle;

    //         // tx_data = 8'h68; // output e
    //         // tx_valid = 1;
    //         end
    //         // Gets here after a successful match of the password
    //         unk_cmd: next_state = init;

    //         // Here if cmd received is unrecognized and sends an error
    //         stor_pw: next_state = init;
    //         // Gets password from user
    //         // Need a way to id the passwords to know how to retrieve them from
    //         // storage
    //         get_pw:
    //         // Send over the requested password and whatever meta data needed
    //         op_res: next_state = init;
    //         // Send the result of the ran command
    //         default: next_state = init;
    //     endcase
    // end

endmodule
