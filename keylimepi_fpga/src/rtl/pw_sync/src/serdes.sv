module serdes(
    input clk,
    input rst_n,

    input serial_in,
    input start_des,
    output [7:0] parallel_out,
    output des_done,

    input [7:0] parallel_in,
    input start_ser,
    output serial_out,
    output ser_done
);

    logic [7:0] parallel_in_s;
    logic [7:0] parallel_out_s;
    logic [2:0] des_count;
    logic [2:0] ser_count;

    assign parallel_out = parallel_out_s;
    assign serial_out = parallel_in_s[ser_count];

    assign des_done = (des_count == 3'b111) ? 1 : 0;
    assign ser_done = (ser_count == 3'b000) ? 1 : 0;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            parallel_in_s <= 0;
            parallel_out_s <= 0;
            des_count <= 3'b000;
            ser_count <= 3'b111;
        end else begin
            parallel_in_s <= parallel_in_s;
            parallel_out_s <= {parallel_out_s[6:0], serial_in};
            des_count <= des_count + 1;
            ser_count <= ser_count - 1;

            if(start_des == 1) begin
                des_count <= 3'b000;
            end

            if(start_ser == 1) begin
                ser_count <= 3'b00;
                parallel_in_s <= parallel_in;
            end
        end
    end

endmodule
