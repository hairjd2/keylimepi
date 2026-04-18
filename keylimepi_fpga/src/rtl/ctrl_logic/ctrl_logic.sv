import keylimepi_pkg::*;

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
    output logic [511:0] wr_data,
    input [511:0] rd_data,
    output logic enb
);
    
    // state machine
    // (* mark_debug = "true" *) enum {init, wait_client, init_resp, wait_pw, check_pw, output_resp, idle, get_addr, wait_for_len, wait_for_len2, send_len, send_data, get_len, get_data} curr_state;
    (* mark_debug = "true" *) enum {init, output_resp, idle, get_addr, wait_for_len, wait_for_len2, send_len, send_data, get_len, get_data} curr_state;

    logic op_type_d, op_type_q;
    (* mark_debug = "true" *) logic [5:0] byte_counter;
    logic [511:0] wr_data_d;
    (* mark_debug = "true" *) logic [511:0] wr_data_q;
    logic [31:0] resp_code_d, resp_code_q;
    logic [11:0] addr_d;
    (* mark_debug = "true" *) logic [11:0] addr_q;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            curr_state <= init;
            byte_counter <= 0;
        end else begin
            curr_state <= curr_state;
            byte_counter <= byte_counter;
            case (curr_state)
                init: begin
                    curr_state <= idle;
                    byte_counter <= 0;
                end
                idle: begin
                    if(rx_valid)
                        curr_state <= get_addr;
                end
                get_addr: begin
                    if(rx_valid) begin
                        if(op_type_q)
                            curr_state <= wait_for_len;
                        else
                            curr_state <= get_len;
                    end
                end
                wait_for_len: begin
                    curr_state <= wait_for_len2;
                end
                wait_for_len2: begin
                    curr_state <= send_len;
                end
                send_len: begin
                    curr_state <= send_data;
                    // case(addr_q[1:0]) // TODO: Make this work, only setting the counter to 0 for some reason
                    //     2'b00: byte_counter = rd_data[485:480];
                    //     2'b01: byte_counter = rd_data[493:488];
                    //     2'b10: byte_counter = rd_data[501:496];
                    //     2'b11: byte_counter = rd_data[509:504];
                    // endcase
                    byte_counter <= '1;
                end
                send_data: begin
                    if(byte_counter == 0) begin
                        curr_state <= output_resp;
                        byte_counter <= 6'h03;
                    end else begin
                        byte_counter <= byte_counter - 1;
                        curr_state <= send_data;
                    end
                end
                get_len: begin
                    if(rx_valid) begin
                        curr_state <= get_data;
                        byte_counter <= '1;
                    end
                end
                get_data: begin
                    if(rx_valid) begin
                        if(byte_counter == 0) begin
                            curr_state <= output_resp;
                            byte_counter <= 6'h03;
                        end else begin
                            byte_counter <= byte_counter - 1;
                            curr_state <= get_data;
                        end
                    end
                end
                output_resp: begin
                    if(byte_counter == 0) begin
                        curr_state <= idle;
                        byte_counter <= 6'h00;
                    end else begin
                        byte_counter <= byte_counter - 1;
                        curr_state <= output_resp;
                    end
                end
                default: begin
                    curr_state <= idle;
                end
            endcase
        end
    end

    always_comb begin

        // wr_data_d = wr_data_q;
        // if(curr_state == get_data)
        //     wr_data_d[(byte_counter+1)*8+1 -: 8] = rx_data;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            op_type_q <= '0;
            wr_data_q <= '0;
            resp_code_q <= '0;
            addr_q <= '0;
        end else begin
            op_type_q <= op_type_d;
            wr_data_q <= wr_data_d;
            resp_code_q <= DONE_RESP; // TODO: Change this once I start looking for errors
            addr_q <= addr_d;
        end
    end

    always_comb begin
        rx_ready = 1;

        if(curr_state == send_len) begin
            case(addr_q[1:0])
                2'b00: tx_data = rd_data[487:480];
                2'b01: tx_data = rd_data[495:488];
                2'b10: tx_data = rd_data[503:496];
                2'b11: tx_data = rd_data[511:504];
            endcase
            tx_valid = 1;
        end else if(curr_state == send_data) begin
            tx_data = rd_data[(byte_counter+1)*8-1 -: 8];
            tx_valid = 1;
        end else if(curr_state == output_resp) begin
            tx_data = resp_code_q[(byte_counter+1)*8-1 -: 8];
            tx_valid = 1;
        end else begin
            tx_data = 0;
            tx_valid = 0;
        end

        // if(curr_state == wait_for_len || curr_state == get_len) begin
        //     addr = {addr_q[11:2], 2'b01};
        // end else begin
        //     addr = addr_q;
        // end

        if(curr_state == idle)
            op_type_d = rx_data[7];
        else
            op_type_d = op_type_q;

        if(curr_state == get_len || curr_state == wait_for_len)
            addr = {addr_q[11:2], 2'b00};
        else
            addr = addr_q;

        if(curr_state == idle)
            addr_d = {rx_data[3:0], addr_q[7:0]};
        else if(curr_state == get_addr)
            addr_d = {addr_q[11:8], rx_data};
        else
            addr_q = addr_q;

        if(curr_state == get_len) begin
            case(addr_q[1:0])
                2'b00: wr_data = {rd_data[511:488], rx_data, rd_data[479:0]};
                2'b01: wr_data = {rd_data[511:496], rx_data, rd_data[487:0]};
                2'b10: wr_data = {rd_data[511:504], rx_data, rd_data[495:0]};
                2'b11: wr_data = {rx_data, rd_data[503:0]};
            endcase
        end else begin
            wr_data = wr_data_q;
        end

        if(curr_state == get_data && rx_valid) begin
            wr_data_d = {wr_data_q[503:0], rx_data};
        end else if(curr_state == idle) begin
            wr_data_d = '0;
        end else begin
            wr_data_d = wr_data_q;
        end

        if((curr_state == get_len && rx_valid == 1) || (curr_state == output_resp && op_type_q == 0))
            we = 1;
        else
            we = 0;

        // if(curr_state == get_len) begin
        //     case(addr_q[1:0])
        //         2'b00: wr_data = {rd_data[511:488], rx_data, rd_data[479:0]};
        //         2'b01: wr_data = {rd_data[511:496], rx_data, rd_data[487:0]};
        //         2'b10: wr_data = {rd_data[511:504], rx_data, rd_data[495:0]};
        //         2'b11: wr_data = {rx_data, rd_data[503:0]};
        //     endcase
        //     we = 1;
        // end else if(curr_state == get_data && byte_counter == 0) begin
        //     wr_data = wr_data_d;
        //     we = 1;
        // end else begin
        //     wr_data = rd_data;
        //     we = 0;
        // end

        enb = 0;
    end
endmodule
