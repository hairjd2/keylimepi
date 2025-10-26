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
    logic tx_ready;

    logic [7:0] rx_fifo_out;
    logic rx_fifo_val;
    logic rx_fifo_rdy;

    logic [7:0] tx_fifo_in;
    logic tx_fifo_val;
    logic tx_fifo_rdy;

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
        .tx_ready(tx_fifo_rdy)
    );

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

    // axis_data_fifo_0 tx_fifo (
    //     .s_axis_aresetn(~rst),  // input wire s_axis_aresetn
    //     .s_axis_aclk(clk),        // input wire s_axis_aclk
    //     .s_axis_tvalid(tx_fifo_val),    // input wire s_axis_tvalid
    //     .s_axis_tready(tx_fifo_rdy),    // output wire s_axis_tready
    //     .s_axis_tdata(tx_fifo_in),      // input wire [7 : 0] s_axis_tdata
    //     .m_axis_tvalid(tx_valid),    // output wire m_axis_tvalid
    //     .m_axis_tready(tx_ready),    // input wire m_axis_tready
    //     .m_axis_tdata(tx_byte)      // output wire [7 : 0] m_axis_tdata
    // );

    rv_fifo #(
  	    .DATA_WIDTH(8),
  	    .FIFO_DEPTH(512)
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

    serial_interface u_serial_ifce (
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