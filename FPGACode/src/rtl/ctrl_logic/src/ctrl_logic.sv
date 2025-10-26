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
    input tx_ready
);
    
    enum {init, valid_pw, bad_pw, idle, unk_cmd, stor_pw, op_res, get_pw} next_state, curr_state;
    enum {short_read, long_read} rd_cmd;
    enum {short_write, long_write} wr_cmd;

    logic [1:0] byte_counter;
    logic [1:0] byte_counter_d;

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
                    if(rx_data == 8'h61 && rx_valid) // Looking for a
                        curr_state <= get_pw; // TODO: Testing for now
                    else
                        curr_state <= idle;
                    byte_counter <= 2'b00;
                end
                get_pw: begin
                    curr_state <= get_pw;
                    byte_counter <= byte_counter + 1;
                    if(byte_counter == 2'b00) begin
                        tx_data <= 8'h61; // output a
                        tx_valid <= 1;
                        curr_state <= get_pw;
                    end else if(byte_counter == 2'b01) begin
                        tx_data <= 8'h62; // output b
                        tx_valid <= 1;
                        curr_state <= get_pw;
                    end else if(byte_counter == 2'b10) begin
                        tx_data <= 8'h63; // output c
                        tx_valid <= 1;
                        curr_state <= get_pw;
                    end else if(byte_counter == 2'b11) begin
                        tx_data <= 8'h64; // output d
                        tx_valid <= 1;
                        curr_state <= idle;
                    end
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
    //         get_pw: begin
    //             next_state = get_pw;
    //             // if(tx_ready) begin
    //             byte_counter_d = byte_counter + 1;
    //             if(byte_counter == 2'b00) begin
    //                 tx_data = 8'h61; // output a
    //                 tx_valid = 1;
    //                 next_state = get_pw;
    //             end else if(byte_counter == 2'b01) begin
    //                 tx_data = 8'h62; // output b
    //                 tx_valid = 1;
    //                 next_state = get_pw;
    //             end else if(byte_counter == 2'b10) begin
    //                 tx_data = 8'h63; // output c
    //                 tx_valid = 1;
    //                 next_state = get_pw;
    //             end else if(byte_counter == 2'b11) begin
    //                 tx_data = 8'h64; // output d
    //                 tx_valid = 1;
    //                 next_state = idle;
    //             end
    //         end
    //         // Send over the requested password and whatever meta data needed
    //         op_res: next_state = init;
    //         // Send the result of the ran command
    //         default: next_state = init;
    //     endcase
    // end

endmodule
