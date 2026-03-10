module branch_logic_mux (
    input  wire [1:0]  i_sel,             // 選択信号 (00:標準, 01:相対, 10:間接)
    input  wire [15:0] i_pc_plus_2,       // PC + 2 (通常進捗)
    input  wire [15:0] i_pc_plus_imm,     // PC + imm (分岐・JAL)
    input  wire [15:0] i_rs1_plus_imm,    // rs1 + imm (JALR)
    output wire [15:0] o_next_pc          // 最終的な次PC値
);

    // 選択信号に基づいたアドレスの決定
    // 2'b00 : 通常の命令実行 (PC + 2)
    // 2'b01 : 条件成立時の分岐 または jal命令 (PC + Relative)
    // 2'b10 : jalr命令 (Register + Offset)
    assign o_next_pc = (i_sel == 2'b10) ? i_rs1_plus_imm :
                       (i_sel == 2'b01) ? i_pc_plus_imm  :
                                          i_pc_plus_2;

endmodule