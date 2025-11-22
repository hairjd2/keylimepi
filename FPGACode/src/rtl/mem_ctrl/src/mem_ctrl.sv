module mem_ctrl (
    input clk,
    input rst_n,

    output logic [0:0] we,
    output logic [12:0] addr,
    output logic [511:0] dout,
    input [511:0] din,

    // AXI-Lite read address
    output [23:0] araddr,
    output arvalid,
    input arready,

    // AXI-Lite read data
    output [511:0] rdata,
    output [1:0] rresp,
    output rvalid,
    output rready, 

    // AXI-Lite write address
    output [23:0] awaddr,
    output awvalid,
    input awready,

    // AXI-Lite write data
    output [511:0] wdata,
    output wvalid,
    input wready,

    // AXI-Lite write response
    input [1:0] bresp,
    input bvalid,
    output bready
);


endmodule
