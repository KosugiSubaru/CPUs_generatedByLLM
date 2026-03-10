module instruction_decoder_field (
    input  wire [15:0] i_instr, // 16ビット命令コード
    output wire [3:0]  o_rd,    // デスティネーションレジスタ番号
    output wire [3:0]  o_rs1,   // ソースレジスタ1番号
    output wire [3:0]  o_rs2,   // ソースレジスタ2番号
    output wire [15:0] o_imm    // 符号拡張済み即値
);

    wire [3:0] opcode;
    assign opcode = i_instr[3:0];

    // 基本的なレジスタフィールドの抽出
    assign o_rd  = i_instr[15:12];
    assign o_rs1 = i_instr[11:8];
    assign o_rs2 = i_instr[7:4];

    // オペコードに基づいた即値の抽出と符号拡張
    // addi(1000), load(1010), jalr(1111) : imm[7:4] (4bit)
    // loadi(1001), jal(1110)             : imm[11:4] (8bit)
    // store(1011)                        : imm[15:12] (4bit)
    // blt(1100), bz(1101)                : imm[15:4] (12bit)
    assign o_imm = (opcode == 4'b1000 || opcode == 4'b1010 || opcode == 4'b1111) ? {{12{i_instr[7]}},  i_instr[7:4]}  :
                   (opcode == 4'b1011)                                           ? {{12{i_instr[15]}}, i_instr[15:12]} :
                   (opcode == 4'b1001 || opcode == 4'b1110)                      ? {{8{i_instr[11]}},  i_instr[11:4]}  :
                   (opcode == 4'b1100 || opcode == 4'b1101)                      ? {{4{i_instr[15]}},  i_instr[15:4]}  :
                   16'h0000;

endmodule