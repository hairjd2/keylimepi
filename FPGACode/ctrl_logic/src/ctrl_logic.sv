module #(
  DATA_WIDTH = 128
) ctrl_logic (
  input clk,
  input rst_n,
  
);
  
enum {init, valid_pw, bad_pw, idle, unk_cmd, stor_pw, op_res, get_pw} next_state, curr_state;
enum {short_read, long_read} rd_cmd;
enum {short_write, long_write} wr_cmd;

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    curr_state <= init;
  end else begin
    curr_state <= next_state;
  end
end

always_comb begin : state_machine
  case (curr_state)
    init:
      // Delay for how many cycles needed to get things sent to reg file
    valid_pw:
      // Send request for master pw (?)
      // Make sure sent master password matches the one given
    bad_pw:
      // If the password does not match, send error message saying that
      // Could have a counter that waits for a certain amount of time if too
      // mny wrong guesses.
    idle:
      // Gets here after a successful match of the password
    unk_cmd:
      // Here if cmd received is unrecognized and sends an error
    stor_pw:
      // Gets password from user
      // Need a way to id the passwords to know how to retrieve them from
      // storage
    get_pw:
      // Send over the requested password and whatever meta data needed
    op_res:
      // Send the result of the ran command
    default: 
  endcase
end

endmodule
