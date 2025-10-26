module ctrl_logic_tb ();
    logic clk;
    logic rst_n;

    logic [7:0] rx_fifo_out;
    logic rx_fifo_val;
    logic rx_fifo_rdy;

    logic [7:0] tx_fifo_in;
    logic tx_fifo_val;
    logic tx_fifo_rdy;
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        rx_fifo_val = 1;
        rx_fifo_out = 8'h61;
        #10;
        // rx_fifo_val = 0;
        // rx_fifo_out = 8'hxx;
        #1000;
        $finish;
    end

    ctrl_logic #(
  	    .DATA_WIDTH(8)
    ) u_ctrl_logic (
        .clk(clk),
        .rst_n(rst_n),
        
        .rx_data(rx_fifo_out),
        .rx_valid(rx_fifo_val),
        .rx_ready(rx_fifo_rdy),

        .tx_data(tx_fifo_in),
        .tx_valid(tx_fifo_val),
        .tx_ready(tx_fifo_rdy)
    );

endmodule