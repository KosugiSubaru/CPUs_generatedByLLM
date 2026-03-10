module imm_gen (
    input  wire [15:0] i_instr, // 16ビット命令コード
    output wire [15:0] o_imm    // 最終的に選択・拡張された16ビット即値
);

    wire [15:0] w_imm_ext4_a;
    wire [15:0] w_imm_ext4_b;
    wire [15:0] w_imm_ext8;
    wire [15:0] w_imm_ext12;

    // 符号拡張ユニットのインスタンス化
    generate
        // addi, load, jalr 用 (instr[7:4])
        imm_gen_ext4 u_ext4_a (
            .i_data (i_instr[7:4]),
            .o_data (w_imm_ext4_a)
        );

        // store 用 (instr[15:12])
        imm_gen_ext4 u_ext4_b (
            .i_data (i_instr[15:12]),
            .o_data (w_imm_ext4_b)
        );

        // loadi, jal 用 (instr[11:4])
        imm_gen_ext8 u_ext8 (
            .i_data (i_instr[11:4]),
            .o_data (w_imm_ext8)
        );

        // blt, bz 用 (instr[15:4])
        imm_gen_ext12 u_ext12 (
            .i_data (i_instr[15:4]),
            .o_data (w_imm_ext12)
        );
    endgenerate

    // オペコードに基づいた即値ソースの選択
    generate
        imm_gen_mux u_mux (
            .i_opcode     (i_instr[3:0]),
            .i_imm_ext4_a (w_imm_ext4_a),
            .i_imm_ext4_b (w_imm_ext4_b),
            .i_imm_ext8   (w_imm_ext8),
            .i_imm_ext12  (w_imm_ext12),
            .o_imm        (o_imm)
        );
    endgenerate

endmodule