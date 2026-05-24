module spi_if (
    input clk,
    input rst_n,
    // Sync request interface
    input sync_req,
    input [11:0] sync_addr,
    output sync_ack,
    // Input AXIS interface of data to write to flash
    input [511:0] spi_wr_axis_data,
    input spi_wr_axis_val,
    output spi_wr_axis_rdy,
    // Output AXIS interfae of data read from flash
    output [511:0] spi_rd_axis_data,
    output spi_rd_axis_val,
    input spi_rd_axis_rdy,
    // SPI I/F
    output CSn,
    output logic MOSI,
    input MISO,
    output SCK
);
    localparam RESET_EN = 8'h66;
    localparam RESET_MEM = 8'h99;

    localparam READ_MEM = 8'h03;
    localparam FAST_READ = 8'h0B;
    localparam WRITE_DIS = 8'h04;
    localparam WRITE_EN = 8'h06;
    localparam PROG_PAGE = 8'h02;

    localparam READ_STAT_REG = 8'h05;
    localparam WRITE_STAT_REG = 8'h01;

    logic [7:0] state_counter;

    enum {init, request_length, get_length, cmd_idle} curr_cmd_state;
    enum {idle, wr_inst, wr_addr, wr_data, rd_inst, rd_addr, rd_data} curr_serdes_state;

    // assign CSn = (curr_cmd_state == cmd_idle) ? 1 : 0; // Once we leave the idle state, we want to chip select the flash

//    always_ff @(posedge clk or negedge rst_n) begin
//        if(!rst_n) begin
//            SCK <= 0;
//        end else begin
//            SCK <= ~SCK;
//        end
//    end

//always_ff @(posedge SCK or negedge rst_n) begin
//    if(!rst_n) begin
//        curr_serdes_state <= idle;
//    end else begin
//        case(curr_serdes_state)
//            idle: begin
//                if(start_rd == 1)
//                    curr_serdes_state <= rd_inst;
//                else if(start_wr == 1)
//                    curr_serdes_state <= wr_inst;
//            end
//            wr_inst: begin
//                if(ser_done == 1)
//                    curr_serdes_state <= wr_addr;
//            end
//            wr_addr: begin
//                if(ser_done == 1)
//                    curr_serdes_state <= wr_data;
//            end
//            wr_data: begin
//                if(ser_done == 1)
//                    curr_serdes_state <= idle;
//            end
//            rd_inst: begin
//                if(ser_done == 1)
//                    curr_serdes_state <= rd_addr;
//            end
//            rd_addr: begin
//                if(ser_done == 1)
//                    curr_serdes_state <= rd_data;
//            end
//            rd_data: begin
//                if(des_done == 1)
//                    curr_serdes_state <= idle;
//            end
//        endcase
//    end
//end

serdes u_serdes (
        .clk(SCK),
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

endmodule