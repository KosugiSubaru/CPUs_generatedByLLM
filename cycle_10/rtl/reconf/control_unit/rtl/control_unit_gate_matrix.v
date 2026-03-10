module control_unit_gate_matrix (
    input  wire [15:0] i_inst_active,
    output wire       o_reg_write,
    output wire       o_mem_write,
    output wire       o_alu_src,
    output wire [3:0] o_alu_op,
    output wire [1:0] o_result_src,
    output wire       o_branch_bz,
    output wire       o_branch_blt,
    output wire       o_jump,
    output wire       o_jump_reg
);

    // 16本の命令識別信号を、各機能制御信号へデコード（マトリクス配線）
    
    // レジスタへの書き込みを行う命令 (Store, Branch以外すべて)
    assign o_reg_write = i_inst_active[0] | i_inst_active[1] | i_inst_active[2] | 
                         i_inst_active[3] | i_inst_active[4] | i_inst_active[5] | 
                         i_inst_active[6] | i_inst_active[7] | i_inst_active[8] | 
                         i_inst_active[9] | i_inst_active[10] | i_inst_active[14] | 
                         i_inst_active[15];

    // データメモリへの書き込みを行う命令 (Store)
    assign o_mem_write = i_inst_active[11];

    // ALUの入力Bに即値を使用する命令 (Addi, Load, Store, Jalr)
    assign o_alu_src   = i_inst_active[8] | i_inst_active[10] | i_inst_active[11] | i_inst_active[15];

    // ALU演算の選択 (基本はOpcodeの下位4ビットをそのまま使用)
    assign o_alu_op    = (i_inst_active[0]) ? 4'b0000 : // add
                         (i_inst_active[1]) ? 4'b0001 : // sub
                         (i_inst_active[2]) ? 4'b0010 : // and
                         (i_inst_active[3]) ? 4'b0011 : // or
                         (i_inst_active[4]) ? 4'b0100 : // xor
                         (i_inst_active[5]) ? 4'b0101 : // not
                         (i_inst_active[6]) ? 4'b0110 : // sra
                         (i_inst_active[7]) ? 4'b0111 : // sla
                         (i_inst_active[8]) ? 4'b0000 : // addi (use add)
                         (i_inst_active[10])? 4'b0000 : // load (use add)
                         (i_inst_active[11])? 4'b0000 : // store (use add)
                         (i_inst_active[15])? 4'b0000 : // jalr (use add)
                         4'b0000;

    // レジスタへの書き戻しデータの選択 (00:ALU, 01:Mem, 10:PC+2, 11:Imm)
    assign o_result_src[0] = i_inst_active[10] | i_inst_active[9];
    assign o_result_src[1] = i_inst_active[14] | i_inst_active[15] | i_inst_active[9];

    // 分岐・ジャンプ制御
    assign o_branch_blt = i_inst_active[12];
    assign o_branch_bz  = i_inst_active[13];
    assign o_jump       = i_inst_active[14] | i_inst_active[15];
    assign o_jump_reg   = i_inst_active[15];

endmodule