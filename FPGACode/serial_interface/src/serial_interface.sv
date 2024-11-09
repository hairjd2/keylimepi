module #(
  DATA_WIDTH = 128
) serial_interface (
  input clk,
  input rst_n,
  
  input [DATA_WIDTH-1:0] tx_data,
  input [DATA_WIDTH/8-1:0] tx_sel, // Need to make sure that the ctrl_logic lines this up right, may not need it
  input tx_valid,
  input tx_ready,

  input uart_rx,

  output [DATA_WIDTH-1:0] rx_data,
  //output [DATA_WIDTH/8-1:0] rx_sel, // might not really need it
  output rx_valid,
  output rx_ready,

  output uart_tx
);

logic [DATA_WIDTH-1:0] tx_data_q;
logic [DATA_WIDTH-1:0] tx_data_d;
logic [DATA_WIDTH/32-1:0] tx_stb; // selects which dword I am writing to
logic [DATA_WIDTH-1:0] rx_data_q;
logic [DATA_WIDTH-1:0] rx_data_d;
//logic [DATA_WIDTH/32-1:0] rx_stb; // selects which dword I am reading from

enum {idle_state, set_ctrl_state, resp_state, write_state} curr_tx_state, next_tx_state;
enum {idle_state, set_ctrl_state, resp_state, read_state} curr_rx_state, next_rx_state;

  always_ff @(posedge clk or negedge rst_n) begin : flip_flop_seq
    if(!rst_n) begin
      tx_data_q <= 'b0;
      rx_data_q <= 'b0;
      //tx_stb <= 'b0;
      //rx_stb <= 'b0;
      curr_tx_state <= idle_state;
      curr_rx_state <= idle_state;
    end else begin
      tx_data_q <= tx_data_d;
      rx_data_q <= rx_data_d;
      //tx_stb <= tx_stb+1; // Should not need to precompute
      //rx_stb <= rx_stb+1;
      curr_tx_state <= next_tx_state;
      curr_rx_state <= next_rx_state;
    end
  end

  axi_uartlite_0 uart(
      .s_axi_aclk(clk),
      .s_axi_aresetn(rst_n),
      .s_axi_awaddr(awaddr),
      .s_axi_awvalid(awvalid),
      .s_axi_awready(awready),
      .s_axi_wdata(tx_data_q[tx_stb]), // Only the first 8 bits need to be set
      .s_axi_wvalid(wvalid),
      .s_axi_wready(wready),
      .s_axi_bresp(bresp),
      .s_axi_bvalid(bvalid),
      .s_axi_bready(bready),
      .s_axi_wstrb(tx_sel[tx_sb]), // Enable all data lines
      .s_axi_araddr('b0), // Not needed since only doing transmit
      .s_axi_arvalid('b0), // Not needed since only doing transmit
      .s_axi_rready('b0), // Not needed since only doing transmit
      .rx(uart_rx),
      .tx(uart_tx)
  );
  
endmodule
