module program_counter_control (
    input  wire [3:0] i_opcode,
    input  wire       i_flag_z,
    input  wire       i_flag_n,
    input  wire       i_flag_v,
    output wire [1:0] o_sel
);

    // 命令のデコード
    wire w_is_blt;
    wire w_is_bz;
    wire w_is_jal;
    wire w_is_jalr;

    assign w_is_blt  = (i_opcode == 4'b1100);
    assign w_is_bz   = (i_opcode == 4'b1101);
    assign w_is_jal  = (i_opcode == 4'b1110);
    assign w_is_jalr = (i_opcode == 4'b1111);

    // 分岐条件の判定 (N^V: 符号付き比較 less than, Z: zero)
    wire w_branch_condition;
    assign w_branch_condition = (w_is_blt & (i_flag_n ^ i_flag_v)) | 
                                (w_is_bz  & i_flag_z);

    // セレクタ制御信号の生成
    // 01: PC + imm (条件を満たしたBranch命令、またはJAL命令)
    wire w_sel_pc_imm;
    assign w_sel_pc_imm = w_branch_condition | w_is_jal;

    // 10: rs1 + imm (JALR命令)
    wire w_sel_rs1_imm;
    assign w_sel_rs1_imm = w_is_jalr;

    // 出力信号の合成 (00: PC+2, 01: PC+imm, 10: rs1+imm)
    assign o_sel[0] = w_sel_pc_imm;
    assign o_sel[1] = w_sel_rs1_imm;

endmodule