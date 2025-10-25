module ctrl_logic #(
  parameter DATA_WIDTH = 128
)(
  input clk,
  input rst_n
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
    init: curr_state <= init;
      // Delay for how many cycles needed to get things sent to reg file
    valid_pw: curr_state <= init;
      // Send request for master pw (?)
      // Make sure sent master password matches the one given
    bad_pw: curr_state <= init;
      // If the password does not match, send error message saying that
      // Could have a counter that waits for a certain amount of time if too
      // mny wrong guesses.
    idle: curr_state <= init;
      // Gets here after a successful match of the password
    unk_cmd: curr_state <= init;
      // Here if cmd received is unrecognized and sends an error
    stor_pw: curr_state <= init;
      // Gets password from user
      // Need a way to id the passwords to know how to retrieve them from
      // storage
    get_pw: curr_state <= init;
      // Send over the requested password and whatever meta data needed
    op_res: curr_state <= init;
      // Send the result of the ran command
    default: curr_state <= init;
  endcase
end

endmodule
