module rv_fifo #(
  	parameter DATA_WIDTH,
  	parameter FIFO_DEPTH
) (
  	input clk,
  	input rst_n,
	
  	input [DATA_WIDTH-1:0] in_data,
  	input in_val,
  	output in_rdy,

  	output [DATA_WIDTH-1:0] out_data,
  	output out_val,
  	input out_rdy,

  	output [$clog2(FIFO_DEPTH):0] data_count,
  	output empty,
  	output full
);
  
	logic [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
  	logic [$clog2(FIFO_DEPTH)-1:0] rd_ptr;
  	logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr;

	logic in_xact;
	logic out_xact;

	logic [$clog2(FIFO_DEPTH):0] count_q;

	assign in_xact = in_val & in_rdy;
	assign out_xact = out_val & out_rdy;

  	assign out_data = mem[rd_ptr];
	assign empty = rd_ptr == wr_ptr;
	assign full = wr_ptr == rd_ptr - 1;
	assign out_val = !empty;
	assign in_rdy = !full;

  	always_ff @(posedge clk or negedge rst_n) begin
  	  	if(!rst_n) begin
  	  	  	rd_ptr <= '0;
  	  	  	wr_ptr <= '0;
			count_q <= '0;
	    end else begin
	        mem[wr_ptr] = in_data;
            if(in_xact && out_xact) begin
                rd_ptr <= rd_ptr + 1;
                wr_ptr <= wr_ptr + 1;
                count_q <= count_q;
            end else if(in_xact) begin
                rd_ptr <= rd_ptr;
                wr_ptr <= wr_ptr + 1;
                count_q <= count_q + 1;
            end else if(out_xact) begin
                rd_ptr <= rd_ptr + 1;
                wr_ptr <= wr_ptr;
                count_q <= count_q - 1;
            end else begin
                rd_ptr <= rd_ptr;
                wr_ptr <= wr_ptr;
                count_q <= count_q;
            end
        end
  	end

endmodule
