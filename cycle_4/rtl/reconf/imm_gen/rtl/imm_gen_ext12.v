module imm_gen_ext12 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 命令の[15:4]ビットを抽出し、MSBである[15]ビット目を上位にコピーして符号拡張を行う
    assign o_imm = {{4{i_instr[15]}}, i_instr[15:4]};

endmodule