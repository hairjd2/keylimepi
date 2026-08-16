module row_shift #(
    parameter DATA_WIDTH = 128;
) (
    input clk;
    input [DATA_WIDTH-1:0] data_in;
    output logic [DATA_WIDTH-1:0] data_out;
);

    logic [127:0] temp_shifted;

// Need to very much test this individually
// Utilizes the fact that s[r,c] = in[r + 4c]
// If row is 0, then no shift; If row is 1, then shift once, then on and on
// Therefore I can just multiply the shift by its row to see how many times it needs t o be shifted over
    genvar r;
    genvar c;
    for(r = 0; r < 4; r++) begin
        for(c = 0; c < 4; c++) begin
            assign temp_shifted[((r+4*c+7)+32*r)%127+7: ((r+4*c+7)+32*r)%127] = data_in[r+4*c+7: r+4*c];
        end
    end

    always_ff @(posedge clk) begin
        data_out <= temp_shift
    end

endmodule