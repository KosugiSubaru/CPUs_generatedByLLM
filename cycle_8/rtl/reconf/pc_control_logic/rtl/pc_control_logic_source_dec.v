module pc_control_logic_source_dec (
    input  wire       i_branch_taken, // 条件分岐成立
    input  wire       i_jal_en,       // JAL命令有効
    input  wire       i_jalr_en,      // JALR命令有効
    output wire [1:0] o_pc_sel        // 00:PC+2, 01:PC+Imm, 10:rs1+Imm
);

    // PC選択信号の生成
    // 論理合成後の回路図において、分岐・ジャンプの成立状況が
    // どのようにPCの更新元を切り替えるかを視覚化する
    
    // bit 0: PC+Imm への遷移（分岐成立 または JAL）
    assign o_pc_sel[0] = i_branch_taken | i_jal_en;

    // bit 1: rs1+Imm への遷移（JALR）
    assign o_pc_sel[1] = i_jalr_en;

endmodule