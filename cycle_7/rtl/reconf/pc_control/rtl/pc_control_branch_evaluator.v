module pc_control_branch_evaluator (
    input  wire i_is_blt,
    input  wire i_is_bz,
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_branch_taken
);

    wire w_less_than;
    wire w_selected_cond;

    // N^V の計算（BLT命令の判定条件）
    pc_control_gate_xor u_xor (
        .i_n         (i_flag_n),
        .i_v         (i_flag_v),
        .o_less_than (w_less_than)
    );

    // 命令の種類に応じて参照するフラグを選択
    // i_is_bz が 1 なら Zフラグ、0 なら LessThan信号 を選択
    pc_control_mux_2to1 u_mux_cond (
        .i_sel (i_is_bz),
        .i_in0 (w_less_than),
        .i_in1 (i_flag_z),
        .o_out (w_selected_cond)
    );

    // 選択された条件が真であり、かつ現在が分岐命令である場合に分岐成立とする
    assign o_branch_taken = w_selected_cond & (i_is_blt | i_is_bz);

endmodule