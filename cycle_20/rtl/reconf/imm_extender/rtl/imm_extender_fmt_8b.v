module imm_extender_fmt_8b (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // loadi, jal用：命令ビット[11:4]を抽出し、最上位ビット[11]を符号ビットとして16ビットに拡張
    assign o_imm[7:0]  = i_instr[11:4];
    assign o_imm[15:8] = {8{i_instr[11]}};

endmodule