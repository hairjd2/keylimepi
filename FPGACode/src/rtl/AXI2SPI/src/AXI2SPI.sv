module AXI2SPI #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 32
)(
    input clk,
    input rst_n,

    // AXI-Lite read address
    input [ADDR_WIDTH-1:0] araddr,
    input arvalid,
    output arready,

    // AXI-Lite read data
    output [DATA_WIDTH-1:0] rdata,
    output [1:0] rresp,
    output rvalid,
    input rready, 

    // AXI-Lite write address
    input [ADDR_WIDTH-1:0] awaddr,
    input awvalid,
    output awready,

    // AXI-Lite write 
    input [DATA_WIDTH-1:0] wdata,
    input wvalid,
    output wready,

    // AXI-Lite write response
    output [1:0] bresp,
    output bvalid,
    input bready,

    // SPI interface
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
    
    enum {idle, read_cmd, read_addr, read_data, write_cmd, write_addr, write_data} curr_state;
    
    logic [4:0] bit_counter;
    logic [ADDR_WIDTH-1:0] address_reg;
    logic [DATA_WIDTH-1:0] rdata_reg;
    logic [DATA_WIDTH-1:0] wdata_reg;

    assign arready = (curr_state == idle) ? 1 : 0;
    assign awready = (curr_state == idle) ? 1 : 0;
    assign rready = (curr_state == idle) ? 1 : 0;
    assign wready = (curr_state == idle) ? 1 : 0;
    assign rdata = rdata_reg;

    assign SCK = (curr_state == idle) ? 0 : clk; // TODO: Double check I can drive the chip at 100MHz
    assign CSn = (curr_state == idle) ? 1 : 0; // Once we leave the idle state, we want to chip select the flash

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            curr_state <= idle;
            address_reg <= 32'hz;
        end else begin
            curr_state <= idle;
            rdata_reg <= rdata_reg;
            wdata_reg <= wdata_reg;
            bit_counter <= bit_counter;
            case(curr_state)
                idle: begin
                    if(arvalid) begin
                        curr_state <= read_cmd;
                        address_reg <= araddr;
                        bit_counter <= 5'h7;
                    end else if(awvalid && wvalid) begin
                        curr_state <= write_cmd;
                        address_reg <= awaddr;
                        wdata_reg <= wdata;
                        bit_counter <= 5'h7;
                    end
                end
                read_cmd: begin
                    if(bit_counter == 0) begin
                        curr_state <= read_addr;
                        bit_counter <= 5'h17;
                    end else begin
                        curr_state <= read_cmd;
                        bit_counter <= bit_counter - 1;
                    end
                    MOSI <= READ_MEM[bit_counter];
                end
                read_addr: begin
                    if(bit_counter == 0) begin
                        curr_state <= read_data;
                        bit_counter <= 5'h7;
                    end else begin
                        curr_state <= read_cmd;
                        bit_counter <= bit_counter - 1;
                    end
                    MOSI <= READ_MEM[bit_counter];
                end
            endcase

        end
    end

endmodule
