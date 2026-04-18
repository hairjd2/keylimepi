module add_round_key (
    input clk;
    input [127:0] key;
    output [127:0] key_s0;
    output [127:0] key_s1;
    output [127:0] key_s2;
    output [127:0] key_s3;
    output [127:0] key_s4; 
    output [127:0] key_s5;
    output [127:0] key_s6;
    output [127:0] key_s7;
    output [127:0] key_s8;
    output [127:0] key_s9;
    output [127:0] key_s10;
);

logic	[31:0]	w0,w1,w2,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17,
							w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33,
							w34, w35, w36, w37, w38, w39, w40, w41, w42, w43;
wire	[31:0]	subword, subword2,subword3,subword4,subword5, subword6, subword7,subword8,subword9,subword10;			
wire	[7:0]	rcon, rcon2,rcon3,rcon4,rcon5, rcon6, rcon7,rcon8,rcon9,rcon10;	

assign w0 = key[127:96];
assign w1 = key[95:64];
assign w2 = key[63:32];
assign w3 = key[31:0];

always_comb begin
    
end
    
endmodule