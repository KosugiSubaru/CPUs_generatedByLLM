module imm_gen (
    input  wire [3:0]  i_opcode,
    input  wire [11:0] i_imm_raw,
    output wire [15:0] o_imm_16bit
);

    wire [15:0] w_imm_ext4;
    wire [15:0] w_imm_ext8;
    wire [15:0] w_imm_ext12;

    // 4ビット符号拡張器のインスタンス化 (addi, load, store, jalr用)
    imm_gen_sign_ext4 u_ext4 (
        .i_imm_4bit  (i_imm_raw[3:0]),
        .o_imm_16bit (w_imm_ext4)
    );

    // 8ビット符号拡張器のインスタンス化 (loadi, jal用)
    imm_gen_sign_ext8 u_ext8 (
        .i_imm_8bit  (i_imm_raw[7:0]),
        .o_imm_16bit (w_imm_ext8)
    );

    // 12ビット符号拡張器のインスタンス化 (blt, bz用)
    imm_gen_sign_ext12 u_ext12 (
        .i_imm_12bit (i_imm_raw[11:0]),
        .o_imm_16bit (w_imm_ext12)
    );

    // オペコードに応じて拡張結果を選択
    // 論理合成後の回路図で、ビット幅ごとの拡張器がMUXで選ばれる様子を視覚化する
    assign o_imm_16bit = (i_opcode == 4'b1100 || i_opcode == 4'b1101) ? w_imm_ext12 : // 12bit
                         (i_opcode == 4'b1001 || i_opcode == 4'b1110) ? w_imm_ext8  : // 8bit
                                                                        w_imm_ext4;   // 4bit (addi, load, store, jalr)

endmodule