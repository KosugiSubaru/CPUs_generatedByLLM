module imm_gen_ext4_s (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // S形式 (store) のビットフィールド抽出
    // 命令ビット [15:12] を抽出し、ビット15を符号ビットとして16bitに拡張
    assign o_imm[3:0]  = i_instr[15:12];
    assign o_imm[15:4] = {12{i_instr[15]}};

endmodule