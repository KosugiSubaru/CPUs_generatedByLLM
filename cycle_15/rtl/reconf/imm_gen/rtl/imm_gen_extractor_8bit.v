module imm_gen_extractor_8bit (
    input  wire [7:0]  i_instr_part,
    output wire [15:0] o_imm
);

    // loadi, jal命令用 (命令の[11:4]ビットを符号拡張)
    // i_instr_part[7]が符号ビットとなる
    assign o_imm = {{8{i_instr_part[7]}}, i_instr_part};

endmodule