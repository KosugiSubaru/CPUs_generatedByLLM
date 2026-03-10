module imm_generator_ext4_high (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // store命令用：命令の15-12ビット目を抽出し、16ビットに符号拡張
    // 第15ビットを符号ビットとして拡張する
    assign o_imm = {{12{i_instr[15]}}, i_instr[15:12]};

endmodule