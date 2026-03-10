module control_unit (
    input  wire [3:0] i_opcode,
    input  wire       i_flag_z,
    input  wire       i_flag_n,
    input  wire       i_flag_v,
    output wire       o_reg_write,
    output wire       o_mem_write,
    output wire [3:0] o_alu_op,
    output wire       o_alu_src_sel,   // 0: rs2, 1: imm
    output wire [1:0] o_mem_to_reg,    // 00: ALU result, 01: Mem data, 10: PC+2
    output wire [1:0] o_pc_sel         // 00: PC+2, 01: PC+imm (Branch/JAL), 10: rs1+imm (JALR)
);

    // 内部ワイヤ：命令識別信号（1-hot形式）
    // [0:add, 1:sub, 2:and, 3:or, 4:xor, 5:not, 6:sra, 7:sla, 
    //  8:addi, 9:loadi, 10:load, 11:store, 12:blt, 13:bz, 14:jal, 15:jalr]
    wire [15:0] w_inst_onehot;

    // 内部ワイヤ：分岐成否
    wire w_branch_taken;

    // 4ビットのオペコードを16ビットの1-hot信号にデコード
    control_unit_decoder_onehot u_decoder (
        .i_opcode (i_opcode),
        .o_onehot (w_inst_onehot)
    );

    // フラグの状態に基づき、条件分岐（blt, bz）が成立するか判定
    control_unit_condition_checker u_cond_checker (
        .i_is_blt  (w_inst_onehot[12]),
        .i_is_bz   (w_inst_onehot[13]),
        .i_flag_z  (i_flag_z),
        .i_flag_n  (i_flag_n),
        .i_flag_v  (i_flag_v),
        .o_taken   (w_branch_taken)
    );

    // 1-hot信号と分岐成否から、具体的な制御信号（RegWrite等）を生成
    control_unit_signal_map u_signal_map (
        .i_inst_onehot   (w_inst_onehot),
        .i_branch_taken  (w_branch_taken),
        .o_reg_write     (o_reg_write),
        .o_mem_write     (o_mem_write),
        .o_alu_op        (o_alu_op),
        .o_alu_src_sel   (o_alu_src_sel),
        .o_mem_to_reg    (o_mem_to_reg),
        .o_pc_sel        (o_pc_sel)
    );

endmodule