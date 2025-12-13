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

    logic [7:0] rx_data;
    logic rx_valid;

    logic [7:0] tx_data;
    logic tx_valid;
    logic tx_ready;

    logic rx_fifo_empty;
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        repeat(10)@(posedge clk);
        rst_n = 1;
        repeat(10)@(posedge clk);
        rx_valid = 0;
        rx_data = 0;
        writedata(8'h02);
        readdata(8'h82);
        readdata(8'h82);
        writedata(8'h03);
        readdata(8'h83);
        writedata(8'h01);
        readdata(8'h81);

        #100000;
        $finish;
    end

    task readdata(input [7:0] cmd);
        rx_valid = 1;
        rx_data = cmd;
        @(posedge clk);
        rx_valid = 1;
        rx_data = 8'h00;
        @(posedge clk);
        rx_valid = 0;
        repeat(130) @(posedge clk);
    endtask

    task writedata(input [7:0] cmd);
        rx_valid = 1;
        rx_data = cmd;
        @(posedge clk);
        rx_valid = 1;
        rx_data = 8'h00;
        @(posedge clk);
        if(cmd != 8'h01) begin
            for(int i = 0; i < 64; i++) begin
                rx_valid = 1;
                rx_data = i[7:0];
                @(posedge clk);
            end
        end else begin
            for(int i = 0; i < 64; i++) begin
                rx_valid = 1;
                rx_data = i[7:0];
                @(posedge clk);
            end
//            @(posedge clk);
            for(int i = 0; i < 64; i++) begin
                rx_valid = 1;
                rx_data = i[7:0];
                @(posedge clk);
            end
        end
        rx_valid = 0;
        repeat(5)@(posedge clk);
    endtask

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

    assign rx_fifo_val = ~rx_fifo_empty;

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

    assign tx_ready = 1;

    sync_fifo #(
        .DEPTH(16),
        .DWIDTH(8)
    ) rx_fifo (
        .rstn(rst_n),               // Active low reset
        .clk(clk),                // Clock
        .wr_en(rx_valid), 				// Write enable
        .rd_en(rx_fifo_rdy), 				// Read enable
        .din(rx_data), 				// Data written into FIFO
        .dout(rx_fifo_out), 				// Data read from FIFO
        .empty(rx_fifo_empty), 				// FIFO is empty when high
        .full() 				// FIFO is full when high
    );

    sync_fifo #(
        .DEPTH(16),
        .DWIDTH(8)
    ) tx_fifo (
        .rstn(rst_n),               // Active low reset
        .clk(clk),                // Clock
        .wr_en(tx_fifo_val), 				// Write enable
        .rd_en(tx_ready), 				// Read enable
        .din(tx_fifo_in), 				// Data written into FIFO
        .dout(tx_data), 				// Data read from FIFO
        .empty(), 				// FIFO is empty when high
        .full(tx_fifo_rdy) 				// FIFO is full when high
    );

    // rv_fifo #(
  	//     .DATA_WIDTH(8),
  	//     .FIFO_DEPTH(16)
    // ) rx_fifo (
    //     .clk(clk),
    //     .rst_n(rst_n),
        
    //     .in_data(rx_data),
    //     .in_val(rx_valid),
    //     .in_rdy(),

    //     .out_data(rx_fifo_out),
    //     .out_val(rx_fifo_val),
    //     .out_rdy(rx_fifo_rdy),

    //     .data_count(),
    //     .empty(),
    //     .full()
    // );

    // rv_fifo #(
  	//     .DATA_WIDTH(8),
  	//     .FIFO_DEPTH(16)
    // ) tx_fifo (
    //     .clk(clk),
    //     .rst_n(rst_n),
        
    //     .in_data(tx_fifo_in),
    //     .in_val(tx_fifo_val),
    //     .in_rdy(tx_fifo_rdy),

    //     .out_data(tx_data),
    //     .out_val(tx_valid),
    //     .out_rdy(tx_ready),

    //     .data_count(),
    //     .empty(),
    //     .full()
    // );

endmodule