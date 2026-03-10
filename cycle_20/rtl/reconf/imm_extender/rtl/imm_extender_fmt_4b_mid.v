module imm_extender_fmt_4b_mid (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 命令のビット[7:4]を抽出し、最上位ビット[7]を符号ビットとして16ビットに拡張
    assign o_imm[3:0]  = i_instr[7:4];
    assign o_imm[15:4] = {12{i_instr[7]}};

endmodule