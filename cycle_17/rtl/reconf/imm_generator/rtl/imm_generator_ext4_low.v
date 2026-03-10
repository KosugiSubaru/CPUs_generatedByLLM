module imm_generator_ext4_low (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 命令の7-4ビット目を抽出し、符号ビット(第7ビット)で16ビットに符号拡張
    assign o_imm = {{12{i_instr[7]}}, i_instr[7:4]};

endmodule