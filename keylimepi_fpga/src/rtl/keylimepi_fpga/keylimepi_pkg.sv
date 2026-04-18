package keylimepi_pkg;
    //=============================================
    // Regmap Addresses
    //=============================================
    // Accessible by control logic
    const logic [31:0] VERSION_ADDR       = 32'h00000000;
    const logic [31:0] SCRATCHPAD_ADDR    = 32'h00000004;
    const logic [31:0] NUM_CREDS_ADDR     = 32'h00000008;
    // const logic [31:0] ADDR            = 32'h0000000C; -- TBD
    // Not accessible by control logic
    const logic [31:0] MST_PW_HASH_ADDR   = 32'h00000010;
    // const logic [31:0] ADDR            = 32'h00000014; -- TBD
    // const logic [31:0] ADDR            = 32'h00000018; -- TBD
    // const logic [31:0] ADDR            = 32'h0000001C; -- TBD

    //=============================================
    // Response Values
    //=============================================
    const logic [31:0] DONE_RESP          = 32'h444F4E45; // "DONE"
    const logic [31:0] BAD_ADDR_RESP      = 32'h554E4446; // "UNDF"
    const logic [31:0] INIT_RESP          = 32'h4B334C50; // "K3LP"
    const logic [31:0] BAD_PW_RESP        = 32'h4E485348; // "NHSH"

endpackage