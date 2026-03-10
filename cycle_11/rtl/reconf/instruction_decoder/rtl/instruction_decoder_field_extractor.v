module instruction_decoder_field_extractor (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_rd,
    output wire [3:0]  o_rs1,
    output wire [3:0]  o_rs2,
    output wire [3:0]  o_opcode,
    output wire [11:0] o_imm_fields
);

    assign o_rd         = i_instr[15:12];
    assign o_rs1        = i_instr[11:8];
    assign o_rs2        = i_instr[7:4];
    assign o_opcode     = i_instr[3:0];
    assign o_imm_fields = i_instr[15:4];

endmodule