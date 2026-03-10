module imm_generator_ext12 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // branch命令用：命令の15-4ビット目を抽出し、16ビットに符号拡張
    // 第15ビットを符号ビットとして拡張する
    assign o_imm = {{4{i_instr[15]}}, i_instr[15:4]};

endmodule