package keylimepi_pkg;
    //=============================================
    // Regmap Addresses
    //=============================================
    // Accessible by control logic 0x00000000 - 0x00000FFF
    parameter logic [31:0] VERSION_ADDR         = 32'h00000000;
    parameter logic [31:0] SCRATCHPAD_ADDR      = 32'h00000004;
    parameter logic [31:0] NUM_CREDS_ADDR       = 32'h00000008;
    // Not accessible by control logic
    parameter logic [31:0] MST_PW_HASH_ADDR     = 32'h00001000;

    //=============================================
    // Response Values
    //=============================================
    parameter logic [31:0] VERSION              = 32'h00000105; // TODO: Change this to a better scheme
    parameter logic [31:0] DONE_RESP            = 32'h444F4E45; // "DONE"
    parameter logic [31:0] BAD_ADDR_RESP        = 32'h554E4446; // "UNDF"
    parameter logic [31:0] INIT_RESP            = 32'h4B334C50; // "K3LP"
    parameter logic [31:0] BAD_PW_RESP          = 32'h4E485348; // "NHSH"

    //=============================================
    // First Byte Bit Positions
    //=============================================
    parameter int OP_TYPE_UPPER            = 7;
    parameter int OP_TYPE_LOWER            = 4;
    parameter int START_ADDR_UPPER         = 3;
    parameter int START_ADDR_LOWER         = 0;

    //=============================================
    // Cred Length Bit Positions
    //=============================================
    parameter int DOMAIN1_UPPER            = 511;
    parameter int DOMAIN1_LOWER            = 504;
    parameter int DOMAIN0_UPPER            = 503;
    parameter int DOMAIN0_LOWER            = 496;
    parameter int USERNAME_UPPER           = 495;
    parameter int USERNAME_LOWER           = 488;
    parameter int PASSWORD_UPPER           = 487;
    parameter int PASSWORD_LOWER           = 480;

    //=============================================
    // Operation Types
    //=============================================
    parameter logic [2:0] DATA_OP             = 23'b000;
    parameter logic [2:0] REG_OP             = 23'b000;

endpackage