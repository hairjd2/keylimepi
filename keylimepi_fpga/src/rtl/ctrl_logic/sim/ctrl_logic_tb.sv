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
    logic [511:0] rd_data;
    logic [511:0] wr_data;

    logic [7:0] rx_data;
    logic rx_valid;
    logic rx_ready;

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
        rx_valid = 0;
        rx_data = 0;
        repeat(10)@(posedge clk);
        rx_valid = 1;
        @(posedge clk);
        writedata(12'h002);
        readdata(12'h002);
        readdata(12'h002);
        writedata(12'h003);
        readdata(12'h003);
        writedata(12'h001);
        readdata(12'h001);

        #100000;
        $finish;
    end

    task readdata(input [11:0] address);
        rx_valid = 1;
        rx_data = {1'b1, 3'b000, address[11:8]};
        @(posedge clk);
        rx_valid = 1;
        rx_data = address[7:0];
        @(posedge clk);
        rx_valid = 0;
        repeat(130) @(posedge clk);
    endtask

    task writedata(input [11:0] address);
        rx_valid = 1;
        rx_data = {1'b0, 3'b000, address[11:8]};
        @(posedge clk);
        wait(rx_ready);
        rx_valid = 1;
        rx_data = address[7:0];
        @(posedge clk);
        wait(rx_ready);
        rx_valid = 1;
        rx_data = 8'h40;
        @(posedge clk);
        wait(rx_ready);
        if(address[1:0] != 2'b01) begin
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
        .dina(wr_data), // Data out of the control logic TODO: change naming
        .douta(rd_data)

        // .clkb(clk),
        // .web(web),
        // .addrb(addrb),
        // .dinb(doutb), // Data out of the control logic TODO: change naming
        // .doutb(dinb),
        // .enb(0)
    );

//    assign rx_fifo_val = ~rx_fifo_empty;

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
        .rd_data(rd_data),
        .wr_data(wr_data),
        .enb(enb)
    );

    assign tx_ready = 1;

     rv_fifo #(
  	     .DATA_WIDTH(8),
  	     .FIFO_DEPTH(16)
     ) rx_fifo (
         .clk(clk),
         .rst_n(rst_n),
        
         .in_data(rx_data),
         .in_val(rx_valid),
         .in_rdy(rx_ready),

         .out_data(rx_fifo_out),
         .out_val(rx_fifo_val),
         .out_rdy(1),

         .data_count(),
         .empty(),
         .full()
     );

    assign tx_ready = 1;

     rv_fifo #(
  	     .DATA_WIDTH(8),
  	     .FIFO_DEPTH(16)
     ) tx_fifo (
         .clk(clk),
         .rst_n(rst_n),
        
         .in_data(tx_fifo_in),
         .in_val(tx_fifo_val),
         .in_rdy(tx_fifo_rdy),

         .out_data(tx_data),
         .out_val(tx_valid),
         .out_rdy(tx_ready),

         .data_count(),
         .empty(),
         .full()
     );

endmodule