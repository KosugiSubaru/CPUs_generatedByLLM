module imm_gen (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_i;
    wire [15:0] w_imm_s;
    wire [15:0] w_imm_u;
    wire [15:0] w_imm_b;
    wire [3:0]  w_opcode;

    assign w_opcode = i_instr[3:0];

    // フォーマット別の即値生成器をインスタンス化
    generate
        imm_gen_sext4_i u_sext_i (
            .i_instr (i_instr),
            .o_imm   (w_imm_i)
        );

        imm_gen_sext4_s u_sext_s (
            .i_instr (i_instr),
            .o_imm   (w_imm_s)
        );

        imm_gen_sext8_u u_sext_u (
            .i_instr (i_instr),
            .o_imm   (w_imm_u)
        );

        imm_gen_sext12_b u_sext_b (
            .i_instr (i_instr),
            .o_imm   (w_imm_b)
        );
    endgenerate

    // オペコードに従い、適切なフォーマットの即値を選択する
    // I型: addi(1000), load(1010), jalr(1111)
    // S型: store(1011)
    // U型: loadi(1001), jal(1110)
    // B型: blt(1100), bz(1101)
    assign o_imm = (w_opcode == 4'b1000 || w_opcode == 4'b1010 || w_opcode == 4'b1111) ? w_imm_i :
                   (w_opcode == 4'b1011) ? w_imm_s :
                   (w_opcode == 4'b1001 || w_opcode == 4'b1110) ? w_imm_u :
                   (w_opcode == 4'b1100 || w_opcode == 4'b1101) ? w_imm_b : 16'b0;

endmodule