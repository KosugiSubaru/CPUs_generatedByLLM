module control_unit_condition_checker (
    input  wire i_is_blt,
    input  wire i_is_bz,
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_taken
);

    // blt: N ^ V (符号付き比較で rs1 < rs2 の状態)
    wire w_blt_match;
    assign w_blt_match = i_flag_n ^ i_flag_v;

    // bz: Z (結果が 0 の状態)
    wire w_bz_match;
    assign w_bz_match = i_flag_z;

    // 分岐条件の成立判定
    assign o_taken = (i_is_blt & w_blt_match) | (i_is_bz & w_bz_match);

endmodule