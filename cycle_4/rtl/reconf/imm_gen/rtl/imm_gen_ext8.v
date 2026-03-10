module imm_gen_ext8 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 命令の[11:4]ビットを抽出し、MSBである[11]ビット目を上位にコピーして符号拡張を行う
    assign o_imm = {{8{i_instr[11]}}, i_instr[11:4]};

endmodule