module keylimepi_fpga_top (
    input clk,
    input rst,
    input uart_rx,
    output uart_tx
);

    logic [7:0] rx_byte;
    logic rx_valid;
    logic [7:0] tx_byte;
    logic tx_valid;

    logic [7:0] rx_fifo_out;
    logic rx_fifo_val;
    logic rx_fifo_rdy;

    rv_fifo #(
  	    .DATA_WIDTH(8),
  	    .FIFO_DEPTH(512)
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
  	    .FIFO_DEPTH(512)
    ) tx_fifo (
        .clk(clk),
        .rst_n(~rst),
        
        .in_data(rx_fifo_out),
        .in_val(rx_fifo_val),
        .in_rdy(rx_fifo_rdy),

        .out_data(tx_byte),
        .out_val(tx_valid),
        .out_rdy(1),

        .data_count(),
        .empty(),
        .full()
    );

    serial_interface u_serial_ifce (
        .clk(clk),
        .rst_n(~rst),
        .rx_uart(uart_rx),
        .rx_byte(rx_byte),
        .rx_valid(rx_valid),
        .tx_uart(uart_tx),
        .tx_byte(tx_byte+1),
        .tx_valid(tx_valid)
    );
    
endmodule