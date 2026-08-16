module cred_sync #(
    parameter ADDR_WIDTH    = 12,
    parameter DATA_WIDTH    = 512
)(
    input clk,
    input rst_n,
    
    input flash_sync,
    input [11:0] flash_sync_addr,
    
    output init_sync_done,

    output [0:0] we,
    output [11:0] addr,
    output [511:0] wr_data,
    input [511:0] rd_data,

    output CSn,
    output MOSI,
    input MISO,
    output SCK
);

    logic bram_sync_req;
    logic [11:0] bram_sync_addr;
    logic bram_sync_ack;
    
    logic spi_sync_req;
    logic [11:0] spi_sync_addr;
    logic spi_sync_ack;

    logic [511:0] bram_wr_axis_data;
    logic bram_wr_axis_val;
    logic bram_wr_axis_rdy;

    logic [511:0] bram_rd_axis_data;
    logic bram_rd_axis_val;
    logic bram_rd_axis_rdy;

    logic [511:0] spi_wr_axis_data;
    logic spi_wr_axis_val;
    logic spi_wr_axis_rdy;

    logic [511:0] spi_rd_axis_data;
    logic spi_rd_axis_val;
    logic spi_rd_axis_rdy;
    
    enum {init, wait_count, write_ram, wait_data, idle, load_ram, write_flash} curr_state;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            curr_state <= init;
        end else begin
            
        end
    end


    bram_if u_bram_if (
        .clk,
        .rst_n,
        // Sync request interface
        .sync_req(bram_sync_req),
        .sync_addr(bram_sync_addr),
        .sync_ack(bram_sync_ack),
        // Input AXIS interface of data to write to BRAM 
        .bram_wr_axis_data,
        .bram_wr_axis_val,
        .bram_wr_axis_rdy,
        // Output AXIS interfae of data read from BRAM
        .bram_rd_axis_data,
        .bram_rd_axis_val,
        .bram_rd_axis_rdy,
        // BRAM port
        .we,
        .addr,
        .wr_data,
        .rd_data
    );

    rv_fifo #(
  	    .DATA_WIDTH(512),
  	    .FIFO_DEPTH(8)
    ) BRAM2Flash (
        .clk,
        .rst_n,
        
        .in_data(bram_rd_axis_data),
        .in_val(bram_rd_axis_val),
        .in_rdy(bram_rd_axis_rdy),

        .out_data(spi_wr_axis_data),
        .out_val(spi_wr_axis_val),
        .out_rdy(spi_wr_axis_rdy),

        .data_count(),
        .empty(),
        .full()
    );

    rv_fifo #(
  	    .DATA_WIDTH(512),
  	    .FIFO_DEPTH(8)
    ) Flash2BRAM (
        .clk,
        .rst_n,
        
        .in_data(spi_rd_axis_data),
        .in_val(spi_rd_axis_val),
        .in_rdy(spi_rd_axis_rdy),

        .out_data(bram_wr_axis_data),
        .out_val(bram_wr_axis_val),
        .out_rdy(bram_wr_axis_rdy),

        .data_count(),
        .empty(),
        .full()
    );

   spi_if u_spi_if (
        .ACLK(clk),
        .ARESETn(rst_n),
        .AWVALID(0),
        .AWREADY(),
        .AWADDR(0),
        .WVALID(0),
        .WREADY(),
        .AWDATA(0),
        .WSTRB(0),
        .BVALID(),
        .BREADY(0),
        .BRESP(),
        .ARVALID(0),
        .ARREADY(),
        .ARADDR(0),
        .RVALID(),
        .RREADY(0),
        .RDATA(),
        .RRESP(),
        .CSn,
        .MOSI,
        .MISO,
        .SCK
    );
    

endmodule
