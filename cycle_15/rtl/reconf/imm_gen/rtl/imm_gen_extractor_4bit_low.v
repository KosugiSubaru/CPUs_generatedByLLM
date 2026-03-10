module imm_gen_extractor_4bit_low (
    input  wire [3:0]  i_instr_part,
    output wire [15:0] o_imm
);

    // addi, load, jalr命令用 (命令の[7:4]ビットを符号拡張)
    // i_instr_part[3]が符号ビットとなる
    assign o_imm = {{12{i_instr_part[3]}}, i_instr_part};

endmodule