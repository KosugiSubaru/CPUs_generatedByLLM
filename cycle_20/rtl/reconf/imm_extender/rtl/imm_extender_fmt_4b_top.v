module imm_extender_fmt_4b_top (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // store命令用：命令ビット[15:12]を抽出し、最上位ビット[15]を符号ビットとして16ビットに拡張
    assign o_imm[3:0]  = i_instr[15:12];
    assign o_imm[15:4] = {12{i_instr[15]}};

endmodule