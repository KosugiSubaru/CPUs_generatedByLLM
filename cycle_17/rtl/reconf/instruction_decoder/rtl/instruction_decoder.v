module instruction_decoder (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire        o_reg_write,
    output wire        o_mem_write,
    output wire        o_mem_read,
    output wire        o_alu_src_b,
    output wire [3:0]  o_alu_op,
    output wire [1:0]  o_reg_src,
    output wire        o_pc_target_src,
    output wire        o_jump_uncond,
    output wire        o_branch_bz,
    output wire        o_branch_blt,
    output wire        o_flag_we
);

    wire [15:0] w_opcode_matches;

    // 1. 命令フィールド（レジスタアドレス）の抽出
    instruction_decoder_field_logic u_field (
        .i_instr    (i_instr),
        .o_rd_addr  (o_rd_addr),
        .o_rs1_addr (o_rs1_addr),
        .o_rs2_addr (o_rs2_addr)
    );

    // 2. オペコードの特定（16本の命令有効ライン生成）
    instruction_decoder_opcode_bank u_bank (
        .i_opcode  (i_instr[3:0]),
        .o_matches (w_opcode_matches)
    );

    // 3. 命令有効ラインに基づく制御信号の生成
    instruction_decoder_control_logic u_control (
        .i_matches       (w_opcode_matches),
        .o_reg_write     (o_reg_write),
        .o_mem_write     (o_mem_write),
        .o_mem_read      (o_mem_read),
        .o_alu_src_b     (o_alu_src_b),
        .o_alu_op        (o_alu_op),
        .o_reg_src       (o_reg_src),
        .o_pc_target_src (o_pc_target_src),
        .o_jump_uncond   (o_jump_uncond),
        .o_branch_bz     (o_branch_bz),
        .o_branch_blt    (o_branch_blt),
        .o_flag_we       (o_flag_we)
    );

endmodule