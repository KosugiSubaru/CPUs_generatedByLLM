module control_unit_enable_generator (
    input  wire [15:0] i_onehot,
    output wire        o_reg_file_wen,
    output wire        o_dmem_wen,
    output wire        o_flag_reg_wen
);

    // ALU R-type命令（0-7）の判定を構造化
    wire [7:0] w_alu_r_group;
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_alu_r_check
            assign w_alu_r_group[i] = i_onehot[i];
        end
    endgenerate

    wire w_is_alu_r = |w_alu_r_group;

    // レジスタファイル書き込み有効信号 (RegWrite)
    // 対象: ALU R-type(0-7), addi(8), loadi(9), load(10), jal(14), jalr(15)
    assign o_reg_file_wen = w_is_alu_r | i_onehot[8] | i_onehot[9] | i_onehot[10] | i_onehot[14] | i_onehot[15];

    // データメモリ書き込み有効信号 (MemWrite)
    // 対象: store(11)
    assign o_dmem_wen = i_onehot[11];

    // フラグレジスタ更新有効信号
    // 対象: 演算結果を伴う命令群 (add, sub, and, or, xor, not, sra, sla, addi)
    assign o_flag_reg_wen = w_is_alu_r | i_onehot[8];

endmodule