import keylimepi_pkg::*;

module regmap #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input ACLK,
    input ARESETn,
    
    input AWVALID,
    output AWREADY,
    input [ADDR_WIDTH-1:0] AWADDR,
    // input AWPROT,

    input WVALID,
    output WREADY,
    input [DATA_WIDTH-1:0] AWDATA,
    input [$clog2(DATA_WIDTH)-1:0] WSTRB,

    output BVALID,
    input BREADY,
    output [1:0] BRESP,

    input  ARVALID,
    output ARREADY,
    input  [ADDR_WIDTH-1:0] ARADDR,
    // input ARPROT,

    output RVALID,
    input  RREADY,
    output [DATA_WIDTH-1:0] RDATA,
    output [1:0] RRESP,

    input sync_pw_hash,
    input sync_num_pw,
    input sync_input,
);

    //=============================================
    // AXI-lite regsters
    //=============================================
    logic arvalid_reg;
    logic [ADDR_WIDTH-1:0] araddr_reg;
    // logic []

    logic awvalid_reg;
    logic [ADDR_WIDTH-1:0] awaddr_reg;

endmodule