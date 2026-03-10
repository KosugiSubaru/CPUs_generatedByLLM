module immediate_generator_formats (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm_a,
    output wire [15:0] o_imm_b,
    output wire [15:0] o_imm_c,
    output wire [15:0] o_imm_d
);

    // ISA定義に基づき、各命令形式から即値フィールドを抽出し符号拡張を行う
    // 合成後の回路図では、命令ビットから各出力への「配線の分岐」として視覚化される

    // Type A: 4bit即値 [7:4] (addi, load, jalr)
    assign o_imm_a = {{12{i_instr[7]}}, i_instr[7:4]};

    // Type B: 8bit即値 [11:4] (loadi, jal)
    assign o_imm_b = {{8{i_instr[11]}}, i_instr[11:4]};

    // Type C: 4bit即値 [15:12] (store)
    assign o_imm_c = {{12{i_instr[15]}}, i_instr[15:12]};

    // Type D: 12bit即値 [15:4] (blt, bz)
    assign o_imm_d = {{4{i_instr[15]}}, i_instr[15:4]};

endmodule