module pc_control_logic_mux_sel_gen (
    input  wire       i_branch_taken,
    input  wire       i_is_jal,
    input  wire       i_is_jalr,
    output wire [1:0] o_pc_sel
);

    // プログラムカウンタの入力ソースを選択する2ビット信号を生成
    // bit[0]: 1 のとき PC + Imm を選択 (Branch成立時、または JAL命令時)
    // bit[1]: 1 のとき rs1 + Imm を選択 (JALR命令時)
    // 00 のときは PC + 2 (通常実行) が選択される

    assign o_pc_sel[0] = i_branch_taken | i_is_jal;
    assign o_pc_sel[1] = i_is_jalr;

endmodule