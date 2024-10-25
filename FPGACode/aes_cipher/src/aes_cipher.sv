module encrypt (
    input clk;
    input [127:0] data_in;
    input [127:0] key;
    output [127:0] data_out;
);
    const num_rounds = 9; // could try to make this generic

    // add round key
    for(int i = 0; i < num_rounds; i++) begin
        // rounds
    end
    // last round
endmodule