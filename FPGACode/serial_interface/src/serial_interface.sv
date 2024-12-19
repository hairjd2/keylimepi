module #(
  DATA_WIDTH = 128 // Defines the size of long read
) serial_interface (
    // General IO
    input clk,
    input rst_n,
    output Interrupt,
          
    // RX CTRL Input
    input rd_in_cmd,
    input rd_in_val,
    output rd_in_rdy,

    // RX CTRL Output
    output [DATA_WIDTH-1:0] rd_out_data,
    output rd_out_cmd, // used to inform the user if its a short or long write
    output rd_out_val,
    input rd_out_rdy,

    // TX CTRL Input
    input wr_in_cmd,
    input [DATA_WIDTH-1:0] wr_in_data
    input wr_in_val,
    output wr_in_rdy

    // TX CTRL Output (is this needed? will not drive anything for now)
    // output wr_out_cmd,
    // output wr_out_val,
    // input wr_out_rdy,
);

// UART AXI interface signals
    // AXI Write Address Channel Signals
    logic [3:0] s_axi_awaddr; 
    logic s_axi_awvalid;
    logic s_axi_awready;

    // AXI Write Channel Signals
    logic [31:0] s_axi_wdata;
    logic s_axi_wvalid;
    logic s_axi_wready;
    logic [3:0] s_axi_wstrb;

    // AXI Write Response Channel Signals
    logic [1:0] s_axi_bresp;
    logic s_axi_bvalid;
    logic s_axi_bready;

    // AXI Read Address Channel Signals
    logic [3:0] s_axi_araddr; 
    logic s_axi_arvalid; 
    logic s_axi_arready;

    // AXI Read Channel Signals
    logic [31:0] s_axi_rdata;
    logic s_axi_rready;
    logic [1:0] s_axi_rresp;
    logic s_axi_rvalid;

    // ctrl register set
    logic ctrl_set_d, ctrl_set_q;

    // read out registers
    logic [DATA_WIDTH-1:0] rd_data_d, rd_data_q;
    logic rd_cmd_d, rd_cmd_q;

    enum {idle_state, preset_status_state, read_status_state, preset_data_state, read_data_state} next_rx_state, curr_rx_state;
    enum {set_ctrl_state, idle_state, resp_state, write_state} next_tx_state, curr_tx_state;

// Can assign these values to default since they're reserved
    assign s_axi_wdata[31:8] = 'b0;
    assign s_axi_wstrb = 4'hf;

    assign rd_out_data = rd_data_q;
    assign rd_out_cmd = rd_cmd_q;

    always_ff @(posedge clk or negedge rst_n) begin : registerBlock
        if(!rst_n) begin
            curr_rx_state <= idle_state;
            curr_tx_state <= set_ctrl_state;
            ctrl_set_q <= 'b0;
            rd_data_q <= 'b0;
            rd_cmd_q <= 'b0;
        end else begin
            curr_rx_state <= next_rx_state;
            curr_tx_state <= next_tx_state;
            ctrl_set_q <= ctrl_set_d;
            rd_data_q <= rd_data_d;
            rd_cmd_q <= rd_cmd_d;
        end
    end

    always_comb begin : next_state_comb
        // RX State machine
        case(curr_rx_state)
            idle_state: begin
                if(rd_in_val && rd_in_rdy)
                    next_rx_state = preset_status_state;
            end
            preset_status_state: begin // status state might be able to be ignored in case interrupt does enough
                if(s_axi_arvalid && s_axi_arready)
                    next_rx_state = read_status_state;
            end
            read_status_state: begin
                if(s_axi_rvalid && s_axi_rdata[0] && !(&s_axi_rresp))
                    next_rx_state = preset_data_state;
            end
            preset_data_state: begin
                if(s_axi_arvalid && s_axi_arready)
                    next_rx_state = read_data_state;
            end
            read_data_state: begin
                if(s_axi_rvalid && ~(&s_axi_rresp)) begin
                    if(!rd_byte_count_q) // If all of the bytes have been read, go to idle
                        next_rx_state = idle_state;
                    else // otherwise keep reading
                        next_rx_state = preset_status_state;
                end
            end
            default: next_rx_state = curr_rx_state;
        endcase

        // TX State machine
        case(curr_tx_state)
            set_ctrl_state: begin // Set the control register
                if(s_axi_wvalid && s_axi_wready)
                    next_tx_state = resp_state;
            end
            resp_state: begin // Read the response from writing or settting control register
                if(!s_axi_bready || ~s_axi_bvalid)
                    next_tx_state = resp_state;
                else begin
                    if(|s_axi_bresp) begin
                        if(~ctrl_set_q)
                            next_tx_state = set_ctrl_state;
                        else
                            next_tx_state = write_state;
                    end 
                    else
                        next_tx_state = idle_state;
                end
            end
            idle_state: begin
                if(wr_in_val && wr_in_rdy)
                    next_tx_state = write_state;
            end
            write_state: begin
                if(s_axi_wready && s_axi_awready) begin
                    if(!wr_byte_count)
                        next_tx_state = idle_state;
                end
            end
            default: next_tx_state = curr_tx_state;
        endcase
    end

    always_comb begin : rx_state_machine
    // Default values for outputs
        rd_in_rdy = 'b0;
        rd_out_val = 'b1;
        s_axi_araddr = 'b0;
        s_axi_arvalid = 'b0;
        s_axi_rready = 'b0;

        case(curr_rx_state)
            idle_state: begin
                s_axi_araddr = 4'h0;
                s_axi_arvalid = 'b0;
                rd_out_val = 'b0;
                rd_in_rdy = 'b1;
                if(data_rx_q)
                    rd_out_val = 'b1;
                if(rd_out_val && rd_out_rdy)
                    data_rx_d = 'b0;
                if(rd_in_val && rd_in_rdy)
                    rd_cmd_d = rd_in_cmd; // TODO: Also need to set counter here
            end
            preset_status_state: begin
                s_axi_araddr = 4'h8;
                s_axi_arvalid = 'b1;
            end
            read_status_state: begin
                s_axi_arvalid = 'b0;
                s_axi_rready = 'b1;
            end
            preset_data_state: begin
                s_axi_araddr = 'b0;
                s_axi_arvalid = 'b1;
            end
            read_data_state: begin
                s_axi_arvalid = 'b0;
                s_axi_rready = 'b1;
                if(s_axi_rvalid && !(&s_axi_rresp)) begin
                    rd_data_d[rd_byte_count_q*8+7: rd_byte_count_q*8] = s_axi_rdata[7:0] // the rest of the data is reserved
                    data_rx_d = 'b1;
                end
            end
        endcase
    end

    always_comb begin : tx_state_machine
        // TODO: make default values
        case(curr_tx_state)
            set_ctrl_state: begin

    end

    // No need to input the signals for the rest since they're named the same thing
    axi_uartlite_0 uart(
        .s_axi_aclk(clk),
        .s_axi_aresetn(rst_n),
        .*
    );
  
endmodule
