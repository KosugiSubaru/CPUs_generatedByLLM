module pc_control (
    input  wire i_is_blt,
    input  wire i_is_bz,
    input  wire i_is_jal,
    input  wire i_is_jalr,
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_pc_sel_target,
    output wire o_pc_sel_rs1
);

    wire w_branch_taken;

    // 分岐条件の評価（BLT命令またはBZ命令の成立判定）
    pc_control_branch_evaluator u_branch_eval (
        .i_is_blt       (i_is_blt),
        .i_is_bz        (i_is_bz),
        .i_flag_z       (i_flag_z),
        .i_flag_n       (i_flag_n),
        .i_flag_v       (i_flag_v),
        .o_branch_taken (w_branch_taken)
    );

    // 次のPCとして「計算されたターゲットアドレス」を採用するかどうかの決定
    // 分岐成立、JAL命令、JALR命令のいずれかであれば1を出力
    pc_control_signal_combiner u_sig_comb (
        .i_branch_taken  (w_branch_taken),
        .i_is_jal        (i_is_jal),
        .i_is_jalr       (i_is_jalr),
        .o_pc_sel_target (o_pc_sel_target)
    );

    // ターゲットアドレスの計算ベースをrs1にするかPCにするかの選択信号
    // JALR命令の時のみ1（rs1ベース）を出力
    assign o_pc_sel_rs1 = i_is_jalr;

endmodule