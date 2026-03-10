module next_pc_logic_cond_eval (
    input  wire i_is_bz,    // 命令がbzであるか
    input  wire i_is_blt,   // 命令がbltであるか
    input  wire i_flag_z,   // フラグレジスタのZ出力
    input  wire i_flag_n,   // フラグレジスタのN出力
    input  wire i_flag_v,   // フラグレジスタのV出力
    output wire o_taken     // 分岐成立信号
);

    wire w_bz_match;
    wire w_blt_match;

    // ISA定義: branch zero (bz)
    // behavior: "if Z, pc<-pc+imm"
    assign w_bz_match = i_is_bz & i_flag_z;

    // ISA定義: branch less than (blt)
    // behavior: "if N^V, pc<-pc+imm"
    assign w_blt_match = i_is_blt & (i_flag_n ^ i_flag_v);

    // いずれかの分岐条件が成立した場合にo_takenをHighにする
    assign o_taken = w_bz_match | w_blt_match;

endmodule