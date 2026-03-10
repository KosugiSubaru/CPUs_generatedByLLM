module imm_gen_ext4h (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 命令の[15:12]ビットを抽出し、MSBである[15]ビット目を上位にコピーして符号拡張を行う
    assign o_imm = {{12{i_instr[15]}}, i_instr[15:12]};

endmodule