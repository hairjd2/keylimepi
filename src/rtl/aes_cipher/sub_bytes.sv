module sub_bytes #(
    parameter DATA_WIDTH = 128;
) (
    input clk;
    input [DATA_WIDTH-1:0] data_in;
    output [DATA_WIDTH-1:0] sub_data_out;
);
    logic [DATA_WIDTH-1:0] tmp_out;

    genvar i;
    generate
        for(int i = 0; i < 16) begin
            sbox sbox0(data_in[i*8+7:i*8]);
        end
    endgenerate

    always_ff @(posedge clk) begin
        sub_data_out <= tmp_out;
    end
endmodule