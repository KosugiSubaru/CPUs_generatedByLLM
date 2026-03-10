module pc_control_logic_branch_resolver (
    input  wire i_is_blt,
    input  wire i_is_bz,
    input  wire i_cond_lt,
    input  wire i_cond_z,
    output wire o_branch_taken
);

    // 分岐成立(Taken)の判定
    // 命令がbltであり、かつ条件N^Vが成立している
    // または
    // 命令がbzであり、かつ条件Zが成立している
    // 回路図上で「命令の種類」と「フラグの状態」がANDゲートで出会う様子を視覚化
    assign o_branch_taken = (i_is_blt && i_cond_lt) || (i_is_bz && i_cond_z);

endmodule