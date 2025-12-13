module keylimepi_fpga_top (
    input clk,
    input rst,
    
    input uart_rx,
    output uart_tx,

    output CSn,
    output MOSI,
    input MISO,
    output SCK
);

    logic [7:0] rx_byte;
    logic rx_valid;
    logic [7:0] tx_byte;
    logic tx_valid;
    logic tx_ready;

    logic [7:0] rx_fifo_out;
    logic rx_fifo_val;
    logic rx_fifo_rdy;

    logic [7:0] tx_fifo_in;
    logic tx_fifo_val;
    logic tx_fifo_rdy;

    // RAM Port A (CMD CTRL)
    logic [0:0] wea;
    logic [11:0] addra;
    logic [511:0] dina;
    logic [511:0] douta;

    // RAM Port B (MEM CTRL)
    logic [0:0] web;
    logic [11:0] addrb;
    logic [511:0] dinb;
    logic [511:0] doutb;
    logic enb;

    logic [23:0] araddr;
    logic arvalid;
    logic arready;

    // AXI-Lite read data
    logic [511:0] rdata;
    logic [1:0] rresp;
    logic rvalid;
    logic rready; 

    // AXI-Lite write address
    logic [511:0] awaddr;
    logic awvalid;
    logic awready;

    // AXI-Lite write 
    logic [511:0] wdata;
    logic wvalid;
    logic wready;

    // AXI-Lite write response
    logic [1:0] bresp;
    logic bvalid;
    logic bready;

    AXI2SPI #(
        .DATA_WIDTH(512),
        .ADDR_WIDTH(32)
    ) u_AXI2SPI (
        .clk(clk),
        .rst_n(~rst),

        // AXI-Lite read address
        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),

        // AXI-Lite read data
        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready), 

        // AXI-Lite write address
        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),

        // AXI-Lite write 
        .wdata(wdata),
        .wvalid(wvalid),
        .wready(wready),

        // AXI-Lite write response
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready),

        // SPI interface
        .CSn(CSn),
        .MOSI(MOSI),
        .MISO(MISO),
        .SCK(SCK)
    );

//    mem_ctrl mem_ctrl (
//        .clk(clk),
//        .rst_n(~rst),

//        // AXI-Lite read address
//        .araddr(araddr),
//        .arvalid(arvalid),
//        .arready(arready),

//        // AXI-Lite read data
//        .rdata(rdata),
//        .rresp(rresp),
//        .rvalid(rvalid),
//        .rready(rready), 

//        // AXI-Lite write address
//        .awaddr(awaddr),
//        .awvalid(awvalid),
//        .awready(awready),

//        // AXI-Lite write 
//        .wdata(wdata),
//        .wvalid(wvalid),
//        .wready(wready),

//        // AXI-Lite write response
//        .bresp(bresp),
//        .bvalid(bvalid),
//        .bready(bready),

//        .we(web),
//        .addr(addrb),
//        .din(dinb),
//        .dout(doutb)
//    );

    pw_ram u_pw_ram (
        .clka(clk),
        .wea(wea),
        .addra(addra),
        .dina(douta), // Data out of the control logic TODO: change naming
        .douta(dina)

        // .clkb(clk),
        // .web(web),
        // .addrb(addrb),
        // .dinb(doutb), // Data out of the control logic TODO: change naming
        // .doutb(dinb),
        // .enb(0)
    );

    ctrl_logic #(
  	    .DATA_WIDTH(8)
    ) u_ctrl_logic (
        .clk(clk),
        .rst_n(~rst),
        
        .rx_data(rx_fifo_out),
        .rx_valid(rx_fifo_val),
        .rx_ready(rx_fifo_rdy),

        .tx_data(tx_fifo_in),
        .tx_valid(tx_fifo_val),
        .tx_ready(tx_fifo_rdy),

        .we(wea),
        .addr(addra),
        .din(dina),
        .dout(douta),
        .enb(enb)
    );

    // Will need error state to transmit message saying this fifo is full
    rv_fifo #(
  	    .DATA_WIDTH(8),
  	    .FIFO_DEPTH(2048)
    ) rx_fifo (
        .clk(clk),
        .rst_n(~rst),
        
        .in_data(rx_byte),
        .in_val(rx_valid),
        .in_rdy(),

        .out_data(rx_fifo_out),
        .out_val(rx_fifo_val),
        .out_rdy(rx_fifo_rdy),

        .data_count(),
        .empty(),
        .full()
    );

    rv_fifo #(
  	    .DATA_WIDTH(8),
  	    .FIFO_DEPTH(2048)
    ) tx_fifo (
        .clk(clk),
        .rst_n(~rst),
        
        .in_data(tx_fifo_in),
        .in_val(tx_fifo_val),
        .in_rdy(tx_fifo_rdy),

        .out_data(tx_byte),
        .out_val(tx_valid),
        .out_rdy(tx_ready),

        .data_count(),
        .empty(),
        .full()
    );

    serial_interface u_serial_if (
        .clk(clk),
        .rst_n(~rst),
        .rx_uart(uart_rx),
        .rx_byte(rx_byte),
        .rx_valid(rx_valid),
        .tx_uart(uart_tx),
        .tx_byte(tx_byte),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready)
    );
    
endmodule