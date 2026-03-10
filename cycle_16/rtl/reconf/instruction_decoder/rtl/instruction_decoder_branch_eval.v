module instruction_decoder_branch_eval (
    input  wire [15:0] i_inst_valid,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire        o_taken
);

    wire w_inst_blt;
    wire w_inst_bz;
    wire w_cond_blt;
    wire w_cond_bz;

    // 命令有効信号の抽出 (One-hot信号の12番目と13番目)
    assign w_inst_blt = i_inst_valid[12];
    assign w_inst_bz  = i_inst_valid[13];

    // 各命令の成立条件 (ISA定義に基づく)
    // blt: N ^ V (符号付き比較で rs1 < rs2 の場合)
    // bz : Z     (直前の結果が 0 の場合)
    assign w_cond_blt = i_flag_n ^ i_flag_v;
    assign w_cond_bz  = i_flag_z;

    // 分岐成立信号の出力
    assign o_taken = (w_inst_blt & w_cond_blt) | 
                     (w_inst_bz  & w_cond_bz);

endmodule