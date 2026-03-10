module pc_selector_branch_check (
    input wire i_flag_z,
    input wire i_flag_n,
    input wire i_flag_v,
    input wire i_branch_en,
    input wire i_branch_type, // 0: BLT (N^V), 1: BZ (Z)
    output wire o_branch_taken
);

    wire w_cond_blt;
    wire w_cond_bz;
    wire w_cond_met;

    assign w_cond_blt = i_flag_n ^ i_flag_v;
    assign w_cond_bz  = i_flag_z;

    // 分岐条件の選択（BLTかBZか）を視覚化するためにMUXをインスタンス化
    pc_selector_mux2_1bit u_mux_cond (
        .i_sel (i_branch_type),
        .i_d0  (w_cond_blt),
        .i_d1  (w_cond_bz),
        .o_q   (w_cond_met)
    );

    // 分岐命令かつ条件成立時に有効化
    assign o_branch_taken = i_branch_en & w_cond_met;

endmodule