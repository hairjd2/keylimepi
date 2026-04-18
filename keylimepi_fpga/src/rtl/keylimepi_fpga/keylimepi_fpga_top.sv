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
    logic [511:0] rd_data;
    logic [511:0] wr_data;

    // RAM Port B (MEM CTRL)
    logic [0:0] web;
    logic [11:0] addrb;
    logic [511:0] dinb;
    logic [511:0] doutb;
    logic enb;
    
    logic flash_sync;
    logic [11:0] flash_sync_addr;
    
    logic init_sync_done;

   pw_sync u_pw_sync (
        .clk(clk),
        .rst_n(~rst),
        
        .flash_sync,
        .flash_sync_addr,
        
        .init_sync_done,

        // SPI interface
        .CSn(CSn),
        .MOSI(MOSI),
        .MISO(MISO),
        .SCK(SCK),

        // BRAM Interface
        .we(web),
        .addr(addrb),
        .rd_data(dinb),
        .wr_data(doutb)
   );

    pw_ram u_pw_ram (
        .clka(clk),
        .wea(wea),
        .addra(addra),
        .dina(wr_data),
        .douta(rd_data),

        .clkb(clk),
        .web(web),
        .addrb(addrb),
        .dinb(doutb), 
        .doutb(dinb),
        .enb(0)
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
        .rd_data(rd_data),
        .wr_data(wr_data),
        .enb(enb)
    );
    
    // uart_buf rx_fifo (
    //     .s_axis_aresetn(~rst),
    //     .s_axis_aclk(clk),
    //     .s_axis_tvalid(rx_valid),
    //     .s_axis_tready(),
    //     .s_axis_tdata(rx_byte),
    //     .m_axis_tvalid(rx_fifo_val),
    //     .m_axis_tready(rx_fifo_rdy),
    //     .m_axis_tdata(rx_fifo_out)
    //   );
      
    //   uart_buf tx_fifo (
    //     .s_axis_aresetn(~rst),
    //     .s_axis_aclk(clk),
    //     .s_axis_tvalid(tx_fifo_val),
    //     .s_axis_tready(tx_fifo_rdy),
    //     .s_axis_tdata(tx_fifo_in),
    //     .m_axis_tvalid(tx_valid),
    //     .m_axis_tready(tx_ready),
    //     .m_axis_tdata(tx_byte)
    //   );
      
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