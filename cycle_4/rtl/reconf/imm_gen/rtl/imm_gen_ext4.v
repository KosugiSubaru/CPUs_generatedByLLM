module imm_gen_ext4 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 命令の[7:4]ビットを抽出し、MSBである[7]ビット目を上位にコピーして符号拡張を行う
    assign o_imm = {{12{i_instr[7]}}, i_instr[7:4]};

endmodule