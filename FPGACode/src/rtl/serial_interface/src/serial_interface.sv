module serial_interface(
    input clk,
    input rst_n,

    input rx_uart,
    output [7:0] rx_byte,
    output rx_valid,

    output tx_uart,
    input [7:0] tx_byte,
    input tx_valid
);

    UART_RX #(
        .CLKS_PER_BIT(869)
    ) pkt_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx_uart(rx_uart),
        .rx_byte(rx_byte),
        .rx_valid(rx_valid)
    );

    UART_TX #(
        .CLKS_PER_BIT(869)
    ) pkt_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_byte(tx_byte),
        .tx_valid(tx_valid),
        .tx_uart(tx_uart)
    );

endmodule