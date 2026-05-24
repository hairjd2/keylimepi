import keylimepi_pkg::*;

module ctrl_logic #(
parameter DATA_WIDTH = 511
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
    output logic enb,

    // Regmap
    output logic [11:0] reg_addr,
    output logic reg_addr_val,
    output logic rd_wrn,
    output logic [31:0] reg_data_in,
    input [31:0] reg_data_out,
    input reg_data_out_val
);
    
    // state machine
    // (* mark_debug = "true" *) enum {init, wait_client, init_resp, wait_pw, check_pw, output_resp, idle, get_addr, wait_for_len, wait_for_len2, send_len, send_data, get_len, get_data} curr_state;
    (* mark_debug = "true" *) enum {init, output_resp, idle, get_addr, wait_for_len, wait_for_len2, send_len, send_data, get_len, get_data} curr_state;

    (* mark_debug = "true" *) logic [3:0] op_type_d, op_type_q;
    (* mark_debug = "true" *) logic [5:0] byte_counter;
    logic [511:0] wr_data_d;
    (* mark_debug = "true" *) logic [511:0] wr_data_q;
    logic [31:0] resp_code_d, resp_code_q;
    logic [11:0] addr_d;
    (* mark_debug = "true" *) logic [11:0] addr_q;
    logic [31:0] reg_data_out_q;

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
                        if(op_type_q[3]) begin // rd == 1; wr == 0
                            curr_state <= wait_for_len;
                        end else begin
                            case(op_type_q[2:0])
                                3'b000: curr_state <= get_len; // Performing a data write
                                3'b001: begin // Performing a register write
                                    byte_counter <= 6'h03;
                                    curr_state <= get_data;
                                end
                                default: curr_state <= idle; // Unexpected op type
                            endcase
                        end
                    end
                end
                wait_for_len: begin
                    case(op_type_q[2:0])
                        3'b000: curr_state <= wait_for_len2; // Performing a data read
                        3'b001: begin // Performing a register read
                            byte_counter <= 6'h03;
                            curr_state <= send_data;
                        end
                        default: curr_state <= idle; // Unexpected op type
                    endcase
                end
                wait_for_len2: begin
                    curr_state <= send_len;
                end
                send_len: begin
                    curr_state <= send_data;
                    if(addr_q[1:0] == 2'b11) // TODO: Make this based on stored length
                        byte_counter <= 6'h3B;
                    else
                        byte_counter <= '1;
                end
                send_data: begin
                    if(byte_counter == 0 && tx_ready == 1) begin
                        curr_state <= output_resp;
                        byte_counter <= 6'h03;
                    end else begin
                        if(tx_ready)
                            byte_counter <= byte_counter - 1;
                        curr_state <= send_data;
                    end
                end
                get_len: begin
                    if(rx_valid) begin
                        curr_state <= get_data;
                        if(addr_q[1:0] == 2'b11)
                            byte_counter <= 6'h3B;
                        else
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
                    if(byte_counter == 0 && tx_ready == 1) begin
                        curr_state <= idle;
                        byte_counter <= 6'h00;
                    end else begin
                        if(tx_ready)
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

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            op_type_q <= '0;
            wr_data_q <= '0;
            resp_code_q <= '0;
            addr_q <= '0;
            reg_data_out_q <= '0;
        end else begin
            op_type_q <= op_type_d;
            wr_data_q <= wr_data_d;
            resp_code_q <= DONE_RESP; // TODO: Change this once I start looking for errors
            addr_q <= addr_d;

            if(reg_data_out_val)
                reg_data_out_q <= reg_data_out;
            else if(curr_state == idle)
                reg_data_out_q <= '0;
            else
                reg_data_out_q <= reg_data_out_q;
        end
    end

    always_comb begin
        rx_ready = 1;

        if(curr_state == send_len) begin
            case(addr_q[1:0])
                2'b00: tx_data = rd_data[PASSWORD_UPPER:PASSWORD_LOWER];
                2'b01: tx_data = rd_data[USERNAME_UPPER:USERNAME_LOWER];
                2'b10: tx_data = rd_data[DOMAIN0_UPPER:DOMAIN0_LOWER];
                2'b11: tx_data = rd_data[DOMAIN1_UPPER:DOMAIN1_LOWER];
            endcase
            tx_valid = 1;
        end else if(curr_state == send_data) begin
            if(op_type_q[2:0] == 3'b000) begin
                tx_data = rd_data[(byte_counter+1)*8-1 -: 8];
                tx_valid = 1;
            end else if(op_type_q[2:0] == 3'b001) begin
                tx_data = reg_data_out_q[(byte_counter+1)*8-1 -: 8];
                tx_valid = 1;
            end else begin
                tx_data = '0;
                tx_valid = 0;
            end
        end else if(curr_state == output_resp) begin
            tx_data = resp_code_q[(byte_counter+1)*8-1 -: 8];
            tx_valid = 1;
        end else begin
            tx_data = 0;
            tx_valid = 0;
        end

        if(curr_state == get_addr && rx_valid && op_type_q == 4'h9) begin // read reg: [3]: 1 for read; [2:0]: 001 for reg op
            reg_addr_val = 1;
            reg_addr = {addr_q[11:8], rx_data};
            rd_wrn = 1;
            reg_data_in = '0;
        end else if(curr_state == output_resp && byte_counter == 6'h03 && op_type_q == 4'h1) begin  // write reg: [3]: 0 for write; [2:0]: 001 for reg op
            reg_addr_val = 1;
            reg_addr = addr_q;
            rd_wrn = 0;
            reg_data_in = wr_data_q[31:0];
        end else begin
            reg_addr_val = 0;
            reg_addr = '0;
            rd_wrn = 0;
            reg_data_in = '0;
        end


        if(curr_state == idle)
            op_type_d = rx_data[7:4];
        else
            op_type_d = op_type_q;

        if(curr_state == get_len || curr_state == wait_for_len)
            addr = {addr_q[11:2], 2'b11};
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
            if(addr_q[1:0] == 2'b11)
                wr_data_d = {rd_data[511:480], wr_data_q[471:0], rx_data};
            else
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

        enb = 0;
    end
endmodule
