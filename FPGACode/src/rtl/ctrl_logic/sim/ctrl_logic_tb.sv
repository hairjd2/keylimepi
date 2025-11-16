module ctrl_logic_tb ();
    logic clk;
    logic rst_n;

    logic [7:0] rx_fifo_out;
    logic rx_fifo_val;
    logic rx_fifo_rdy;

    logic [7:0] tx_fifo_in;
    logic tx_fifo_val;
    logic tx_fifo_rdy;

    logic [0:0] wea;
    logic [11:0] addra;
    logic [511:0] dina;
    logic [511:0] douta;
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        @(posedge clk);
        rx_fifo_val = 1;
        rx_fifo_out = 8'h83;
        wait(rx_fifo_rdy);
        @(posedge clk);
        rx_fifo_val = 1;
        rx_fifo_out = 8'h00;
        wait(rx_fifo_rdy);
        @(posedge clk);
        rx_fifo_val = 0;
//        rx_fifo_out = 8'hZZ;
        // rx_fifo_val = 0;
        // rx_fifo_out = 8'hxx;
        repeat(66) @(posedge clk);
        rx_fifo_val = 1;
        rx_fifo_out = 8'h03;
        wait(rx_fifo_rdy);
        @(posedge clk);
        rx_fifo_val = 1;
        rx_fifo_out = 8'h00;
        wait(rx_fifo_rdy);
        @(posedge clk);
        for(int i = 0; i < 64; i++) begin
            rx_fifo_val = 1;
            rx_fifo_out = i[7:0];
            wait(rx_fifo_rdy);
            @(posedge clk);
        end
        rx_fifo_val = 0;
        repeat(5)@(posedge clk);
        rx_fifo_val = 1;
        rx_fifo_out = 8'h83;
        wait(rx_fifo_rdy);
        @(posedge clk);
        rx_fifo_val = 1;
        rx_fifo_out = 8'h00;
        wait(rx_fifo_rdy);
        @(posedge clk);
        rx_fifo_val = 0;
        #100000;
        $finish;
    end

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

endmodule