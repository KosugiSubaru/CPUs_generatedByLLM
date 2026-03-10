module next_pc_logic_branch_resolver (
    input  wire i_is_blt,
    input  wire i_is_bz,
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_taken
);

    wire w_blt_condition;
    wire w_bz_condition;

    // blt (Branch Less Than): 符号付き比較結果 (N ^ V) を判定
    assign w_blt_condition = i_flag_n ^ i_flag_v;

    // bz (Branch Zero): ゼロフラグ (Z) を判定
    assign w_bz_condition = i_flag_z;

    // 命令の種類に応じて分岐成立信号(taken)を出力
    // blt命令かつ条件成立、またはbz命令かつ条件成立の場合にHighとなる
    assign o_taken = (i_is_blt & w_blt_condition) | (i_is_bz & w_bz_condition);

endmodule