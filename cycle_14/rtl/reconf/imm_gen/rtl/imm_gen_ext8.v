module imm_gen_ext8 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // L形式 (loadi, jal) のビットフィールド抽出
    // 命令ビット [11:4] を抽出し、ビット11を符号ビットとして16bitに拡張
    assign o_imm[7:0]  = i_instr[11:4];
    assign o_imm[15:8] = {8{i_instr[11]}};

endmodule