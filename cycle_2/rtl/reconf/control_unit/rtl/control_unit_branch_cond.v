module control_unit_branch_cond (
    input  wire [15:0] i_inst,    // 1-hot 命令有効信号 (12:blt, 13:bz, 14:jal, 15:jalr)
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire [1:0]  o_pc_sel
);

    wire w_cond_blt;
    wire w_cond_bz;
    wire w_take_rel_branch;
    wire w_take_rel_jump;
    wire w_take_abs_jump;

    // ISA定義に基づく分岐条件の判定
    // blt (opcode 1100): if N ^ V
    assign w_cond_blt = i_inst[12] & (i_flag_n ^ i_flag_v);

    // bz (opcode 1101): if Z
    assign w_cond_bz  = i_inst[13] & i_flag_z;

    // Relative Jump (PC + imm) を選択する条件:
    // 成立した条件分岐(blt, bz) または 無条件ジャンプ(jal)
    assign w_take_rel_branch = w_cond_blt | w_cond_bz;
    assign w_take_rel_jump   = i_inst[14];

    // Absolute Jump (rs1 + imm) を選択する条件:
    // jalr命令
    assign w_take_abs_jump   = i_inst[15];

    // PC選択信号のエンコード
    // 00: PC + 2
    // 01: PC + imm (Relative)
    // 10: rs1 + imm (Absolute)
    assign o_pc_sel[0] = w_take_rel_branch | w_take_rel_jump;
    assign o_pc_sel[1] = w_take_abs_jump;

endmodule