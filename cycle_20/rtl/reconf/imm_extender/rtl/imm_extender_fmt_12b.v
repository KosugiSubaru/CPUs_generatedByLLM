module imm_extender_fmt_12b (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 分岐命令用：命令ビット[15:4]を抽出し、最上位ビット[15]を符号ビットとして16ビットに拡張
    assign o_imm[11:0]  = i_instr[15:4];
    assign o_imm[15:12] = {4{i_instr[15]}};

endmodule