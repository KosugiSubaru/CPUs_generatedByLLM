module ctrl_unit_pc_logic (
    input  wire [15:0] i_active,       // デコーダからの命令有効信号 (One-Hot)
    input  wire        i_flag_z,       // 1クロック前のフラグ: Zero
    input  wire        i_flag_n,       // 1クロック前のフラグ: Negative
    input  wire        i_flag_v,       // 1クロック前のフラグ: Overflow
    output wire [1:0]  o_pc_sel        // 00: PC+2, 01: PC+imm, 10: rs1+imm
);

    // 内部条件判定ワイヤ
    wire w_branch_blt_taken;
    wire w_branch_bz_taken;
    wire w_jump_jal_active;
    wire w_jump_jalr_active;

    // ISA: branch less than (opcode 1100) -> if N^V
    assign w_branch_blt_taken = i_active[12] & (i_flag_n ^ i_flag_v);

    // ISA: branch zero (opcode 1101) -> if Z
    assign w_branch_bz_taken = i_active[13] & i_flag_z;

    // ISA: jump and link (opcode 1110) -> Always taken
    assign w_jump_jal_active = i_active[14];

    // ISA: jump and link register (opcode 1111) -> Always taken
    assign w_jump_jalr_active = i_active[15];

    // pc_regへの選択信号生成
    // o_pc_sel[0]: PC+imm を選択する条件 (blt成立 または bz成立 または jal)
    assign o_pc_sel[0] = w_branch_blt_taken | w_branch_bz_taken | w_jump_jal_active;

    // o_pc_sel[1]: rs1+imm を選択する条件 (jalr)
    assign o_pc_sel[1] = w_jump_jalr_active;

endmodule