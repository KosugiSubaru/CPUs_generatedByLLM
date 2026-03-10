module control_unit (
    input  wire [3:0] i_opcode,
    output wire       o_reg_write,
    output wire       o_mem_write,
    output wire       o_alu_src,
    output wire [3:0] o_alu_op,
    output wire [1:0] o_result_src,
    output wire       o_branch_bz,
    output wire       o_branch_blt,
    output wire       o_jump,
    output wire       o_jump_reg
);

    wire [15:0] w_inst_active;

    // 4bitのOpcodeを16本の命令有効信号（One-hot）に変換
    control_unit_decoder_4to16 u_decoder (
        .i_opcode (i_opcode),
        .o_dec    (w_inst_active)
    );

    // 命令有効信号から各データパスを制御するゲート信号群を生成
    control_unit_gate_matrix u_matrix (
        .i_inst_active (w_inst_active),
        .o_reg_write   (o_reg_write),
        .o_mem_write   (o_mem_write),
        .o_alu_src     (o_alu_src),
        .o_alu_op      (o_alu_op),
        .o_result_src  (o_result_src),
        .o_branch_bz   (o_branch_bz),
        .o_branch_blt  (o_branch_blt),
        .o_jump        (o_jump),
        .o_jump_reg    (o_jump_reg)
    );

endmodule