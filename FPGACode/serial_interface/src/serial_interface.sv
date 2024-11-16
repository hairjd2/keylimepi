module #(
  DATA_WIDTH = 128
) serial_interface (
    input clk,
    input rst_n,
          
    input [DATA_WIDTH-1:0] tx_data,
    input [DATA_WIDTH/32-1:0] tx_sel, // Need to make sure that the ctrl_logic lines this up right, may not need it
    input tx_valid,
    input tx_ready,

    input uart_rx,

    output [DATA_WIDTH-1:0] rx_data,
  //output [DATA_WIDTH/8-1:0] rx_sel, // might not really need it
    output rx_valid,
    output rx_ready,
    
    input rx,
    output tx
);

// UART AXI interface signals
logic [3:0] s_axi_awaddr; 
logic s_axi_awvalid;
logic s_axi_awready;
logic [31:0] s_axi_wdata;
logic s_axi_wvalid;
logic s_axi_wready;
logic [3:0] s_axi_wstrb;
logic [1:0] s_axi_bresp;
logic s_axi_bvalid;
logic s_axi_bready;
logic [3:0] s_axi_araddr; 
logic s_axi_arvalid; 
logic s_axi_arready;
logic [31:0] s_axi_rdata;
logic s_axi_rready;
logic [1:0] s_axi_rresp;
logic s_axi_rvalid;

logic [DATA_WIDTH-1:0] tx_data_q;
logic [DATA_WIDTH-1:0] rx_data_q;
logic [DATA_WIDTH-1:0] tx_data_d;
logic [DATA_WIDTH-1:0] rx_data_d;
logic [DATA_WIDTH/8-1:0] tx_stb;
logic [DATA_WIDTH/8-1:0] tx_stb;

enum {idle_state, set_ctrl_state, resp_state, rd_data_state, wr_data_state} curr_state, next_state;

assign s_axi_wdata[31:8] = 'b0;
assign s_axi_wstrb = 4'hf;

    always_ff @(posedge clk or negedge rst_n) begin : flip_flop_seq
        tx_data_q <= tx_data_d;
        rx_data_q <= rx_data_d;
        tx_stb <= tx_stb+1; // Should not need to precompute
        rx_stb <= rx_stb+1;
        curr_tx_state <= next_tx_state;
        curr_rx_state <= next_rx_state;
      
        if(!rst_n) begin
            tx_data_q <= 'b0;
            rx_data_q <= 'b0;
            tx_stb <= 'b0;
            rx_stb <= 'b0;
            curr_tx_state <= idle_state;
            curr_rx_state <= idle_state;
        end else if(start_tx) begin
            tx_stb <= 'b0;
            rx_stb <= 'b0;
        end
    end

    always_comb begin : state_machine
        s_axi_awaddr = 'b0;
        s_axi_awvalid = 1;
        s_axi_wdata[7:0] = 'b0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        rx_valid 
        case (curr_state)
            set_ctrl_state:
                s_axi_awaddr = 4'hc; // write to ctrl register address
                s_axi_awvalid = 1;
                s_axi_wvalid = 1;
                s_axi_wdata = 'b0;
                if(wready)
                    next_state = idle_state;
                else
                    next_state = set_ctrl_state;
            idle_state:
                
            resp_state:
            rd_data_state:
            wr_data_state:
        endcase
    end

    axi_uartlite_0 uart(
        .s_axi_aclk(clk),
        .s_axi_aresetn(rst_n),
        .*
    );
  
endmodule
