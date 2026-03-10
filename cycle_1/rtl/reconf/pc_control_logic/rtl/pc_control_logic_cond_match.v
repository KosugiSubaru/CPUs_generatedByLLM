module pc_control_logic_cond_match (
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_cond_z,
    output wire o_cond_lt
);

    // Branch Zero (bz) の成立条件: Zフラグが1であること
    assign o_cond_z  = i_flag_z;

    // Branch Less Than (blt) の成立条件: NフラグとVフラグの排他的論理和
    // 符号付き整数の比較において、結果が負かつオーバーフローしていない、
    // または結果が正かつオーバーフローしている（＝真の結果が負）状態を判定
    assign o_cond_lt = i_flag_n ^ i_flag_v;

endmodule