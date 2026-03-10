module control_unit_branch_evaluator (
    input  wire [15:0] i_onehot,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire        o_pc_jump_taken, // 0: PC+2, 1: Jump/Branch Target
    output wire        o_pc_target_sel  // 0: PC+imm (Branch/JAL), 1: rs1+imm (JALR)
);

    // 条件判定の論理式（ISA定義に基づく）
    wire w_cond_blt;
    wire w_cond_bz;

    // blt: N ^ V (符号付き比較で rs1 < rs2 の状態)
    assign w_cond_blt = i_flag_n ^ i_flag_v;

    // bz: Z (結果がゼロの状態)
    assign w_cond_bz  = i_flag_z;

    // 命令と条件の組み合わせ
    wire w_taken_blt;
    wire w_taken_bz;
    wire w_taken_jump;

    assign w_taken_blt  = i_onehot[12] & w_cond_blt; // opcode 1100
    assign w_taken_bz   = i_onehot[13] & w_cond_bz;  // opcode 1101
    assign w_taken_jump = i_onehot[14] | i_onehot[15]; // jal(1110) or jalr(1111)

    // 最終的なPC更新選択信号の出力
    // 論理合成後の回路図で、各条件がORゲートに集約される様子を視覚化する
    assign o_pc_jump_taken = w_taken_blt | w_taken_bz | w_taken_jump;

    // PC計算ターゲットの選択（JALRのみレジスタ相対、他はPC相対）
    assign o_pc_target_sel = i_onehot[15];

endmodule