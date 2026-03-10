module control_unit (
    input  wire [3:0] i_opcode,
    output wire [3:0] o_alu_op,
    output wire       o_reg_write,
    output wire       o_mem_write,
    output wire       o_alu_src_sel,
    output wire [1:0] o_wb_sel,
    output wire [1:0] o_imm_sel,
    output wire       o_branch_en,
    output wire       o_branch_type,
    output wire       o_jump_en,
    output wire       o_jalr_sel
);

    wire [15:0] w_instr_active;

    // 4ビットのOpcodeを16本の個別命令信号に展開
    control_unit_decoder_4to16 u_decoder (
        .i_opcode       (i_opcode),
        .o_instr_active (w_instr_active)
    );

    // 展開された命令信号から各制御信号を生成
    // LOADI命令で誤った即値形式が選択されるのを防ぐため、o_imm_sel信号を正しく接続
    control_unit_op_logic u_op_logic (
        .i_instr_active (w_instr_active),
        .o_alu_op       (o_alu_op),
        .o_reg_write    (o_reg_write),
        .o_mem_write    (o_mem_write),
        .o_alu_src_sel  (o_alu_src_sel),
        .o_wb_sel       (o_wb_sel),
        .o_imm_sel      (o_imm_sel),
        .o_branch_en    (o_branch_en),
        .o_branch_type  (o_branch_type),
        .o_jump_en      (o_jump_en),
        .o_jalr_sel     (o_jalr_sel)
    );

endmodule