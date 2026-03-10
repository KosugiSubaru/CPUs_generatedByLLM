module imm_gen_ext4_i (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // I形式 (addi, load, jalr) のビットフィールド抽出
    // 命令ビット [7:4] を抽出し、ビット7を符号ビットとして16bitに拡張
    assign o_imm[3:0]  = i_instr[7:4];
    assign o_imm[15:4] = {12{i_instr[7]}};

endmodule