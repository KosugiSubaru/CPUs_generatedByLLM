module pc_calc_branch_logic (
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    input  wire i_branch_bz,
    input  wire i_branch_blt,
    output wire o_condition_met
);

    wire w_less_than_met;
    wire w_zero_met;

    // ISA定義: blt (Branch Less Than) の判定条件は N ^ V
    assign w_less_than_met = i_flag_n ^ i_flag_v;

    // ISA定義: bz (Branch Zero) の判定条件は Z
    assign w_zero_met = i_flag_z;

    // 命令の種類に応じて最終的な分岐成立条件を出力
    assign o_condition_met = (i_branch_blt & w_less_than_met) | 
                             (i_branch_bz  & w_zero_met);

endmodule