module inst_decoder (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_opcode,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire [11:0] o_imm_raw_15_4
);

    wire [3:0] slice_out [3:0];
    genvar i;

    generate
        for (i = 0; i < 4; i = i + 1) begin : slice_gen
            inst_decoder_slice u_inst_decoder_slice (
                .i_bits (i_instr[i*4 +: 4]),
                .o_bits (slice_out[i])
            );
        end
    endgenerate

    assign o_opcode       = slice_out[0]; // bits [3:0]
    assign o_rs2_addr     = slice_out[1]; // bits [7:4]
    assign o_rs1_addr     = slice_out[2]; // bits [11:8]
    assign o_rd_addr      = slice_out[3]; // bits [15:12]
    assign o_imm_raw_15_4 = {slice_out[3], slice_out[2], slice_out[1]}; // bits [15:4]

endmodule