module control_unit (
    input  wire [3:0]  i_opcode,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_b_sel,
    output wire [1:0]  o_wb_sel,
    output wire        o_reg_file_wen,
    output wire        o_dmem_wen,
    output wire        o_flag_reg_wen,
    output wire        o_pc_jump_taken,
    output wire        o_pc_target_sel
);

    wire [15:0] w_onehot;

    // 1. オペコードを16ビットのOne-Hot信号に変換
    control_unit_onehot_decoder u_onehot_decoder (
        .i_opcode (i_opcode),
        .o_onehot (w_onehot)
    );

    // 2. ALU関連の制御信号生成
    control_unit_alu_selector u_alu_selector (
        .i_onehot          (w_onehot),
        .o_alu_op          (o_alu_op),
        .o_alu_src_b_sel   (o_alu_src_b_sel)
    );

    // 3. レジスタ書き戻しデータの選択信号生成
    control_unit_writeback_selector u_writeback_selector (
        .i_onehot (w_onehot),
        .o_wb_sel (o_wb_sel)
    );

    // 4. 分岐・ジャンプの判定信号生成
    control_unit_branch_evaluator u_branch_evaluator (
        .i_onehot        (w_onehot),
        .i_flag_z        (i_flag_z),
        .i_flag_n        (i_flag_n),
        .i_flag_v        (i_flag_v),
        .o_pc_jump_taken (o_pc_jump_taken),
        .o_pc_target_sel (o_pc_target_sel)
    );

    // 5. 各種書き込み有効信号（Enable）の生成
    control_unit_enable_generator u_enable_generator (
        .i_onehot       (w_onehot),
        .o_reg_file_wen  (o_reg_file_wen),
        .o_dmem_wen      (o_dmem_wen),
        .o_flag_reg_wen  (o_flag_reg_wen)
    );

endmodule