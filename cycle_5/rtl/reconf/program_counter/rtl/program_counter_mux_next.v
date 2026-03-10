module program_counter_mux_next (
    input  wire [15:0] i_pc_plus_2,     // 通常歩進 (PC+2)
    input  wire [15:0] i_pc_plus_imm,   // 相対分岐・ジャンプ (PC+imm)
    input  wire [15:0] i_rs1_plus_imm,  // レジスタ間接ジャンプ (rs1+imm)
    input  wire [1:0]  i_sel,           // 選択信号 (Control Unitより)
    output wire [15:0] o_next_pc
);

    // 選択ロジック
    // 2'b00: PC+2 (通常の命令実行)
    // 2'b01: PC+imm (blt, bz, jal)
    // 2'b10: rs1+imm (jalr)
    assign o_next_pc = (i_sel == 2'b00) ? i_pc_plus_2 :
                       (i_sel == 2'b01) ? i_pc_plus_imm :
                       (i_sel == 2'b10) ? i_rs1_plus_imm :
                                          i_pc_plus_2;

endmodule