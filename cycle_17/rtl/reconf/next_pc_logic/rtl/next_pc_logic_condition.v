module next_pc_logic_condition (
    input  wire i_f_z,
    input  wire i_f_n,
    input  wire i_f_v,
    input  wire i_branch_bz,
    input  wire i_branch_blt,
    output wire o_cond_met
);

    wire w_bz_met;
    wire w_blt_met;

    // branch zero 条件判定: Zフラグが1の時に成立
    assign w_bz_met  = i_branch_bz & i_f_z;

    // branch less than 条件判定: N(負)フラグとV(オーバーフロー)フラグが異なる時に成立 (N ^ V)
    assign w_blt_met = i_branch_blt & (i_f_n ^ i_f_v);

    // 要求された分岐命令の条件が満たされているかを出力
    assign o_cond_met = w_bz_met | w_blt_met;

endmodule