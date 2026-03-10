module control_unit_branch_decoder (
    input  wire [15:0] i_inst_onehot,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire [1:0]  o_pc_sel
);

    // 関連する命令信号の抽出 (視覚的対応用)
    wire w_inst_blt  = i_inst_onehot[12];
    wire w_inst_bz   = i_inst_onehot[13];
    wire w_inst_jal  = i_inst_onehot[14];
    wire w_inst_jalr = i_inst_onehot[15];

    // 分岐条件の判定 (ISA定義に基づく)
    // blt: N ^ V (符号付き比較で rs1 < rs2 の場合)
    // bz : Z (結果がゼロの場合)
    wire w_cond_blt = i_flag_n ^ i_flag_v;
    wire w_cond_bz  = i_flag_z;

    // 分岐成立信号の生成
    wire w_branch_taken = (w_inst_blt & w_cond_blt) | (w_inst_bz & w_cond_bz);

    // PC選択信号の生成ロジック
    // o_pc_sel[0]: 1 のとき PC+imm を選択 (条件分岐成立時、または jal 時)
    // o_pc_sel[1]: 1 のとき rs1+imm を選択 (jalr 時)
    // 00: PC+2, 01: PC+imm, 10: rs1+imm
    assign o_pc_sel[0] = w_branch_taken | w_inst_jal;
    assign o_pc_sel[1] = w_inst_jalr;

endmodule