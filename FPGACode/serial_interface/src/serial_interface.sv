module serial_interface(
    input clk,
    input rst,
    input rx_uart,
    output tx_uart
);

    logic [7:0] rx_byte;
    logic rx_valid;

    UART_RX #(
        .CLKS_PER_BIT(869)
    ) pkt_rx (
        .clk(clk),
        .rst_n(~rst),
        .rx_uart(rx_uart),
        .rx_byte(rx_byte),
        .rx_valid(rx_valid)
    );

    UART_TX #(
        .CLKS_PER_BIT(869)
    ) pkt_tx (
        .clk(clk),
        .rst_n(~rst),
        // .tx_byte(8'h41),
        // .tx_valid(1),
        .tx_byte(rx_byte),
        .tx_valid(rx_valid),
        .tx_uart(tx_uart)
    );

endmodule