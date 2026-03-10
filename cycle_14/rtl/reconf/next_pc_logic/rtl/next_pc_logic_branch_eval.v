module next_pc_logic_branch_eval (
    input  wire [15:0] i_active, // デコーダからのOne-Hot命令信号
    input  wire [2:0]  i_flags,  // [2]:V, [1]:N, [0]:Z
    output wire [1:0]  o_pc_sel  // 00: PC+2, 01: PC+imm, 10: rs1+imm
);

    // フラグの抽出
    wire w_f_z = i_flags[0];
    wire w_f_n = i_flags[1];
    wire w_f_v = i_flags[2];

    // 分岐・ジャンプ命令の有効信号抽出
    wire w_inst_blt  = i_active[12];
    wire w_inst_bz   = i_active[13];
    wire w_inst_jal  = i_active[14];
    wire w_inst_jalr = i_active[15];

    // ISA定義に基づく条件判定
    // blt: N^V, bz: Z
    wire w_condition_met = (w_inst_blt & (w_f_n ^ w_f_v)) | (w_inst_bz & w_f_z);

    // 遷移先アドレスの選択信号生成
    // bit[0]: PC+imm を選択 (条件成立時、または無条件ジャンプjal)
    assign o_pc_sel[0] = w_condition_met | w_inst_jal;

    // bit[1]: rs1+imm を選択 (jalr命令)
    assign o_pc_sel[1] = w_inst_jalr;

endmodule