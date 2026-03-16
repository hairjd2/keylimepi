module bram_if (
    input clk,
    input rst_n,
    // Sync request interface
    input sync_req,
    input [11:0] sync_addr,
    output sync_ack,
    // Input AXIS interface of data to write to BRAM 
    input [511:0] bram_wr_axis_data,
    input bram_wr_axis_val,
    output bram_wr_axis_rdy,
    // Output AXIS interfae of data read from BRAM
    output [511:0] bram_rd_axis_data,
    output bram_rd_axis_val,
    input bram_rd_axis_rdy,
    // BRAM port
    output [0:0] we,
    output [11:0] addr,
    output [511:0] wr_data,
    input [511:0] rd_data
);

enum {idle, rd_word, wr_word} curr_state;
logic [11:0] sync_addr_s;
logic [1:0] word_count;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        curr_state <= idle;
        sync_addr_s <= 0;
        word_count <= 0;
    end else begin
        curr_state <= curr_state;
        sync_addr_s <= sync_addr_s;

        case (curr_state)
            idle: begin
                if(sync_req) begin
                    curr_state <= rd_word;
                    sync_addr_s <= sync_addr;
                end else if(bram_wr_axis_val) begin
                    curr_state <= wr_word;
                    word_count <= 0;
                end
            end
            rd_word: begin
                
            end 
            wr_word: begin
                if(!bram_wr_axis_val) begin
                end
            end
        endcase
    end
end

endmodule