module imm_gen_mux (
    input  wire [3:0]  i_opcode,      // 命令オペコード
    input  wire [15:0] i_imm_ext4_a,  // instr[7:4]からの拡張即値 (addi, load, jalr用)
    input  wire [15:0] i_imm_ext4_b,  // instr[15:12]からの拡張即値 (store用)
    input  wire [15:0] i_imm_ext8,    // instr[11:4]からの拡張即値 (loadi, jal用)
    input  wire [15:0] i_imm_ext12,   // instr[15:4]からの拡張即値 (blt, bz用)
    output wire [15:0] o_imm           // 選択された即値
);

    // オペコードに応じて適切な拡張済み即値を選択
    assign o_imm = (i_opcode == 4'b1000 || i_opcode == 4'b1010 || i_opcode == 4'b1111) ? i_imm_ext4_a :
                   (i_opcode == 4'b1011)                                              ? i_imm_ext4_b :
                   (i_opcode == 4'b1001 || i_opcode == 4'b1110)                       ? i_imm_ext8   :
                   (i_opcode == 4'b1100 || i_opcode == 4'b1101)                       ? i_imm_ext12  :
                   16'h0000;

endmodule