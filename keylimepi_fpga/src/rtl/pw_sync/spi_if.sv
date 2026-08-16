module spi_if (
    input ACLK,
    input ARESETn,
    
    input AWVALID,
    output AWREADY,
    input [23:0] AWADDR,
    // input AWPROT,

    input WVALID,
    output WREADY,
    input [511:0] AWDATA,
    input [8:0] WSTRB,

    output BVALID,
    input BREADY,
    output [1:0] BRESP,

    input  ARVALID,
    output ARREADY,
    input  [ADDR_WIDTH-1:0] ARADDR,
    // input ARPROT,

    output RVALID,
    input  RREADY,
    output [DATA_WIDTH-1:0] RDATA,
    output [1:0] RRESP,
    
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
    localparam WR_DISABLE = 8'h04;
    localparam WR_ENABLE = 8'h06;
    localparam PROG_PAGE = 8'h02;

    localparam READ_STAT_REG = 8'h05;
    localparam WRITE_STAT_REG = 8'h01;

    logic [7:0] state_counter;

    //=============================================
    // AXI-lite regsters
    //=============================================
    logic arvalid_reg;
    logic [ADDR_WIDTH-1:0] araddr_reg;
    logic rvalid_reg;
    logic [DATA_WIDTH-1:0] rdata_reg;
    logic [1:0] rresp;

    logic slv_rden;
    logic slv_wren;

    enum {idle, set_cs, send_cmd, send_addr, send_data, rd_data} curr_state;

    // enum {idle, wr_inst, wr_addr, wr_data, rd_inst, rd_addr, rd_data} curr_serdes_state;

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