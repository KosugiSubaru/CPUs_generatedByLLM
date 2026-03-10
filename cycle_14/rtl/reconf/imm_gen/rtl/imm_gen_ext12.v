module imm_gen_ext12 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // B形式 (blt, bz) のビットフィールド抽出
    // 命令ビット [15:4] を抽出し、ビット15を符号ビットとして16bitに拡張
    assign o_imm[11:0]  = i_instr[15:4];
    assign o_imm[15:12] = {4{i_instr[15]}};

endmodule