module esp_ctrl(
    input clk,
    input rst,
    input uart_rx,
    output uart_tx
);

    wire [127:0] uart_rx_data;
    wire uart_rx_valid;
    wire uart_rx_ready;

     serial_interface mon(
         .clk(clk),
         .rst(rst),
         .uart_rx(uart_rx),
         .uart_tx(uart_tx),

         .tx_in_dat(uart_rx_data),
         .tx_in_val(uart_rx_valid),
         .tx_out_rdy(uart_rx_ready),

         .rx_out_dat(uart_rx_data),
         .rx_out_val(uart_rx_valid),
         .rx_in_rdy(uart_rx_ready)
     );

//    serial_interface mon(
//        .clk(clk),
//        .rst(rst),
//        .uart_rx(uart_tx),
//        .uart_tx(uart_rx),

//        .tx_in_dat(128'h00000000000074657374746573745C6E),
//        .tx_in_val(1'b1),
//        .tx_out_rdy(uart_rx_ready),

//        .rx_out_dat(uart_rx_data),
//        .rx_out_val(uart_rx_valid),
//        .rx_in_rdy(1'b0)
//    );

endmodule