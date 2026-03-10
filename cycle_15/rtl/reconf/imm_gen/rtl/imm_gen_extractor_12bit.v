module imm_gen_extractor_12bit (
    input  wire [11:0] i_instr_part,
    output wire [15:0] o_imm
);

    // branch less than (blt), branch zero (bz)命令用
    // 命令の[15:4]ビットを抽出し、最上位ビット（bit 11）を符号ビットとして符号拡張を行う
    assign o_imm = {{4{i_instr_part[11]}}, i_instr_part};

endmodule