module mem_ctrl #(
    parameter ADDR_WIDTH    = 12,
    parameter DATA_WIDTH    = 512
)(
    input clk,
    input rst_n,
    
    input [11:0] address,
    input refresh,

    output logic [0:0] we,
    output logic [11:0] addr,
    output logic [511:0] dout,
    input [511:0] din,

    output CSn,
    output logic MOSI,
    input MISO,
    output SCK
);

    localparam RESET_EN = 8'h66;
    localparam RESET_MEM = 8'h99;

    localparam READ_MEM = 8'h03;
    localparam WRITE_DIS = 8'h04;
    localparam WRITE_EN = 8'h06;
    localparam PROG_PAGE = 8'h02;

    localparam READ_STAT_REG = 8'h05;
    localparam WRITE_STAT_REG = 8'h01;
    
    // enum {init, idle, read_cmd, read_addr, read_data, write_cmd, write_addr, write_data} curr_state;
    enum {init, request_length, get_length, cmd_idle} curr_cmd_state;
    enum {idle, wr_inst, wr_addr, wr_data, rd_inst, rd_addr, rd_data} curr_serdes_state;

    logic [7:0] byte_in;
    logic [7:0] byte_out;

    logic start_des;
    logic des_done;
    logic start_ser;
    logic ser_done;

    logic start_rd;
    logic start_wr;
    logic SPIdone;

    assign SCK = (curr_cmd_state == cmd_idle) ? 0 : clk; // TODO: Double check I can drive the chip at 100MHz
    assign CSn = (curr_cmd_state == cmd_idle) ? 1 : 0; // Once we leave the idle state, we want to chip select the flash

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            curr_serdes_state <= idle;
        end else begin
            case(curr_serdes_state)
                idle: begin
                    if(start_rd == 1)
                        curr_serdes_state <= rd_inst;
                    else if(start_wr == 1)
                        curr_serdes_state <= wr_inst;
                end
                wr_inst: begin
                    if(ser_done == 1)
                        curr_serdes_state <= wr_addr;
                end
                wr_addr: begin
                    if(ser_done == 1)
                        curr_serdes_state <= wr_data;
                end
                wr_data: begin
                    if(ser_done == 1)
                        curr_serdes_state <= idle;
                end
                rd_inst: begin
                    if(ser_done == 1)
                        curr_serdes_state <= rd_addr;
                end
                rd_addr: begin
                    if(ser_done == 1)
                        curr_serdes_state <= rd_data;
                end
                rd_data: begin
                    if(des_done == 1)
                        curr_serdes_state <= idle;
                end
            endcase
        end
    end

    serdes u_serdes (
        .clk(clk),
        .rst_n(rst_n),

        .serial_in(MISO),
        .start_des(start_des),
        .parallel_out(byte_in),
        .des_done(des_done),

        .parallel_in(byte_out),
        .start_ser(start_ser),
        .serial_out(MOSI),
        .ser_done(ser_done)
    );

//    always_ff @(posedge clk or negedge rst_n) begin
//        if(!rst_n) begin
//            curr_state <= idle;
//            address_reg <= 32'hz;
//        end else begin
//            curr_state <= idle;
//            rdata_reg <= rdata_reg;
//            wdata_reg <= wdata_reg;
//            bit_counter <= bit_counter;
//            case(curr_state)
//                idle: begin
//                    if(arvalid) begin
//                        curr_state <= read_cmd;
//                        address_reg <= araddr;
//                        bit_counter <= 5'h7;
//                    end else if(awvalid && wvalid) begin
//                        curr_state <= write_cmd;
//                        address_reg <= awaddr;
//                        wdata_reg <= wdata;
//                        bit_counter <= 5'h7;
//                    end
//                end
//                read_cmd: begin
//                    if(bit_counter == 0) begin
//                        curr_state <= read_addr;
//                        bit_counter <= 5'h17;
//                    end else begin
//                        curr_state <= read_cmd;
//                        bit_counter <= bit_counter - 1;
//                    end
//                    MOSI <= READ_MEM[bit_counter];
//                end
//                read_addr: begin
//                    if(bit_counter == 0) begin
//                        curr_state <= read_data;
//                        bit_counter <= 5'h7;
//                    end else begin
//                        curr_state <= read_cmd;
//                        bit_counter <= bit_counter - 1;
//                    end
//                    MOSI <= READ_MEM[bit_counter];
//                end
//            endcase

//        end
//    end

endmodule
