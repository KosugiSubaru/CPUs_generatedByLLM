module imm_generator_ext8 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // loadi, jal命令用：命令の11-4ビット目を抽出し、16ビットに符号拡張
    // 第11ビットを符号ビットとして拡張する
    assign o_imm = {{8{i_instr[11]}}, i_instr[11:4]};

endmodule