module pc_control_logic (
    input  wire       i_is_blt,
    input  wire       i_is_bz,
    input  wire       i_is_jal,
    input  wire       i_is_jalr,
    input  wire       i_flag_z,
    input  wire       i_flag_n,
    input  wire       i_flag_v,
    output wire [1:0] o_pc_sel
);

    wire w_cond_z;
    wire w_cond_lt;
    wire w_branch_taken;

    // 1. フラグ状態に基づいた条件成立判定
    // ZフラグやN^Vフラグを論理合成し、条件が満たされているかを出力
    pc_control_logic_cond_match u_cond_match (
        .i_flag_z  (i_flag_z),
        .i_flag_n  (i_flag_n),
        .i_flag_v  (i_flag_v),
        .o_cond_z  (w_cond_z),
        .o_cond_lt (w_cond_lt)
    );

    // 2. 命令の種類と条件判定結果の照合
    // 実行中の命令が分岐命令であり、かつ判定結果が真である場合に「分岐成立」とする
    pc_control_logic_branch_resolver u_resolver (
        .i_is_blt       (i_is_blt),
        .i_is_bz        (i_is_bz),
        .i_cond_lt      (w_cond_lt),
        .i_cond_z       (w_cond_z),
        .o_branch_taken (w_branch_taken)
    );

    // 3. 次PC選択信号の生成
    // 分岐成立(Taken)か、無条件ジャンプ(JAL/JALR)かに基づき、PCモジュールのMUX選択信号を生成
    pc_control_logic_mux_sel_gen u_sel_gen (
        .i_branch_taken (w_branch_taken),
        .i_is_jal       (i_is_jal),
        .i_is_jalr      (i_is_jalr),
        .o_pc_sel       (o_pc_sel)
    );

endmodule