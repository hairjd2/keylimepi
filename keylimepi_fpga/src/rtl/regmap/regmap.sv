import keylimepi_pkg::*;

module regmap (
    // TODO: In the future might switch to AXI-lite for a more assured interface
    // Just want to go simple now since it feels like overkill
    // input ACLK,
    // input ARESETn,
    
    // input AWVALID,
    // output AWREADY,
    // input [ADDR_WIDTH-1:0] AWADDR,
    // // input AWPROT,

    // input WVALID,
    // output WREADY,
    // input [DATA_WIDTH-1:0] AWDATA,
    // input [$clog2(DATA_WIDTH)-1:0] WSTRB,

    // output BVALID,
    // input BREADY,
    // output [1:0] BRESP,

    // input  ARVALID,
    // output ARREADY,
    // input  [ADDR_WIDTH-1:0] ARADDR,
    // // input ARPROT,

    // output RVALID,
    // input  RREADY,
    // output [DATA_WIDTH-1:0] RDATA,
    // output [1:0] RRESP,

    input clk,
    input rst_n,

    input [31:0] reg_addr,
    input reg_addr_val,
    input rd_wrn,
    input [31:0] reg_data_in,
    output logic [31:0] reg_data_out,
    output logic reg_data_out_val,

    input sync_pw_hash,
    input sync_num_pw,
    input sync_input
);

    //=============================================
    // Registers
    //=============================================
    logic [31:0] version_reg;
    logic [31:0] scratchpad_reg;
    logic [31:0] num_creds_reg;
    logic [31:0] mst_pw_hash_reg;

    // Read Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_data_out <= '0;
            reg_data_out_val <= 0;
        end else begin
            if(reg_addr_val && rd_wrn) begin
                reg_data_out_val <= 1;
                case(reg_addr)
                    VERSION_ADDR:           reg_data_out <= version_reg;
                    SCRATCHPAD_ADDR:        reg_data_out <= scratchpad_reg;
                    NUM_CREDS_ADDR:         reg_data_out <= num_creds_reg;
                    default:                reg_data_out <= BAD_ADDR_RESP;
                endcase
            end else begin
                reg_data_out <= '0;
                reg_data_out_val <= 0;
            end
        end
    end

    // Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            version_reg             <= '0;
            scratchpad_reg          <= '0;
            num_creds_reg           <= '0;
            mst_pw_hash_reg         <= '0;
        end else begin
            version_reg <= VERSION;
            // scratchpad_reg <= scratchpad_reg;
            // num_creds_reg <= num_creds_reg;
            if(reg_addr_val && !rd_wrn) begin
                case(reg_addr)
                    VERSION_ADDR:           ; // Read only
                    SCRATCHPAD_ADDR:        scratchpad_reg <= reg_data_in;
                    NUM_CREDS_ADDR:         num_creds_reg <= reg_data_in;
                    default:                ;
                endcase
            end
        end
    end

    // //=============================================
    // // AXI-lite regsters
    // //=============================================
    // logic arvalid_reg;
    // logic [ADDR_WIDTH-1:0] araddr_reg;
    // logic rvalid_reg;
    // logic [DATA_WIDTH-1:0] rdata_reg;
    // logic [1:0] rresp;

    // logic slv_rden;
    // logic slv_wren;

    // logic [31:0] default_write;

    // logic awvalid_reg;
    // logic [ADDR_WIDTH-1:0] awaddr_reg;
    // logic wvalid_reg;
    // logic [DATA_WIDTH-1:0] wdata_reg;
    // logic bvalid_reg;
    // logic [1:0] bresp_reg;

    // assign RDATA = rdata_reg ? RVALID : '0;

    // assign 

    // // Read Data
    // always_ff @(posedge ACLK or negedge ARESETn) begin
    //     if(!ARESETn) begin
    //         rdata_reg <= '0;
    //     end else begin
    //         if(slv_rden) begin
    //             case araddr_reg
    //                 VERSION_ADDR:           rdata_reg <= version_reg;
    //                 SCRATCHPAD_ADDR:        rdata_reg <= scratchpad_reg;
    //                 NUM_CREDS_REG:          rdata_reg <= num_creds_reg;
    //                 default:                rdata_reg <= BAD_ADDR_RESP;
    //             endcase
    //         end
    //     end
    // end

    // always_ff @(posedge ACLK or negedge ARESETn) begin
    //     if(!ARESETn) begin
    //         slv_rden <= '0;
    //     end
    // end

    // // Write Data
    // always_ff @(posedge ACLK or negedge ARESETn) begin
    //     if(!ARESETn) begin
    //         version_reg <= VERSION;
    //         scratchpad_reg <= VERSION;
    //         num_creds_reg <= '0;
    //         mst_pw_hash_reg <= '0;
    //     end else begin
    //         if(slv_wren) begin
    //             case(awaddr_reg)
    //                 VERSION_ADDR:           default_write <= BAD_ADDR_RESP; // Read only
    //                 SCRATCHPAD_ADDR:        scratchpad_reg <= wdata_reg;
    //                 NUM_CREDS_ADDR          num_creds_reg <= wdata_reg;
    //                 default:                default_write <= BAD_ADDR_RESP;
    //             endcase
    //         end
    //     end
    // end

    // // AXI Write logic
    // always_ff @(posedge ACLK or negedge ARESETn) begin
    //     if (!ARESETn) begin
    //         awaddr_reg <= '0;
    //         awvalid_reg <= 0;
    //         wdata_reg <= '0;
    //         wvalid <= 0;
    //     end else begin
    //         awaddr_reg <= AWADDR;
    //         awvalid_reg <= AWVALID;
    //         wdata_reg <= WDATA;
    //         wvalid <= WVALID;
    //     end
    // end


endmodule