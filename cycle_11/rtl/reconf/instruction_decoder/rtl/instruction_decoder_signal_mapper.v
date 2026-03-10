module instruction_decoder_signal_mapper (
    input  wire [15:0] i_inst_active,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_b,
    output wire        o_reg_write_en,
    output wire        o_mem_write_en,
    output wire        o_mem_to_reg,
    output wire [1:0]  o_pc_src_sel,
    output wire [1:0]  o_imm_sel,
    output wire [1:0]  o_wb_sel,
    output wire        o_is_branch,
    output wire        o_is_jump_link
);

    // ALU演算の選択：R-type(0-7)の各演算、またはそれ以外（計算が必要な命令）はADD(0000)を使用
    assign o_alu_op[0] = i_inst_active[1] | i_inst_active[3] | i_inst_active[5] | i_inst_active[7];
    assign o_alu_op[1] = i_inst_active[2] | i_inst_active[3] | i_inst_active[6] | i_inst_active[7];
    assign o_alu_op[2] = i_inst_active[4] | i_inst_active[5] | i_inst_active[6] | i_inst_active[7];
    assign o_alu_op[3] = 1'b0;

    // ALUの第2入力に即値を使用する命令：addi(8), loadi(9), load(10), store(11), jalr(15)
    assign o_alu_src_b = i_inst_active[8] | i_inst_active[9] | i_inst_active[10] | i_inst_active[11] | i_inst_active[15];

    // レジスタ書き込みを行う命令：branch(12,13)とstore(11)以外すべて
    assign o_reg_write_en = i_inst_active[0] | i_inst_active[1] | i_inst_active[2] | i_inst_active[3] | 
                            i_inst_active[4] | i_inst_active[5] | i_inst_active[6] | i_inst_active[7] | 
                            i_inst_active[8] | i_inst_active[9] | i_inst_active[10] | i_inst_active[14] | 
                            i_inst_active[15];

    assign o_mem_write_en = i_inst_active[11];
    assign o_mem_to_reg   = i_inst_active[10];

    // 次のPCソースの選択：00=PC+2, 01=PC+imm (JALのみ), 10=rs1+imm (JALRのみ)
    // 条件分岐(12,13)は next_pc_selector 内で判定結果に基づいて 00 か 01 を動的に選ぶため、ここでは 00 とする
    assign o_pc_src_sel[0] = i_inst_active[14];
    assign o_pc_src_sel[1] = i_inst_active[15];

    // 即値拡張形式の選択：00=4bitA (addi, load, jalr), 01=4bitB (store), 10=8bit (loadi, jal), 11=12bit (branch)
    assign o_imm_sel[0] = i_inst_active[11] | i_inst_active[12] | i_inst_active[13];
    assign o_imm_sel[1] = i_inst_active[9]  | i_inst_active[14] | i_inst_active[12] | i_inst_active[13];

    // 書き戻しデータの選択：00=ALU, 01=Mem, 10=PC+2 (JAL/JALR), 11=Imm (loadi)
    assign o_wb_sel[0] = i_inst_active[10] | i_inst_active[9];
    assign o_wb_sel[1] = i_inst_active[14] | i_inst_active[15] | i_inst_active[9];

    assign o_is_branch    = i_inst_active[12] | i_inst_active[13];
    assign o_is_jump_link = i_inst_active[14] | i_inst_active[15];

endmodule