module instruction_decoder (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire [11:0] o_imm_fields,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_b,
    output wire        o_reg_write_en,
    output wire        o_mem_write_en,
    output wire        o_mem_to_reg,
    output wire [1:0]  o_pc_src_sel,
    output wire [1:0]  o_imm_sel,
    output wire [1:0]  o_wb_sel,
    output wire        o_is_branch,
    output wire        o_is_jump_link
);

    wire [3:0]  w_opcode;
    wire [15:0] w_inst_active;

    instruction_decoder_field_extractor u_extractor (
        .i_instr      (i_instr),
        .o_rd         (o_rd_addr),
        .o_rs1        (o_rs1_addr),
        .o_rs2        (o_rs2_addr),
        .o_opcode     (w_opcode),
        .o_imm_fields (o_imm_fields)
    );

    instruction_decoder_op_onehot u_onehot (
        .i_opcode      (w_opcode),
        .o_inst_active (w_inst_active)
    );

    instruction_decoder_signal_mapper u_mapper (
        .i_inst_active   (w_inst_active),
        .o_alu_op        (o_alu_op),
        .o_alu_src_b     (o_alu_src_b),
        .o_reg_write_en  (o_reg_write_en),
        .o_mem_write_en  (o_mem_write_en),
        .o_mem_to_reg    (o_mem_to_reg),
        .o_pc_src_sel    (o_pc_src_sel),
        .o_imm_sel       (o_imm_sel),
        .o_wb_sel        (o_wb_sel),
        .o_is_branch     (o_is_branch),
        .o_is_jump_link  (o_is_jump_link)
    );

endmodule