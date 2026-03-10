module pc_control (
    input  wire [15:0] i_pc,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire        i_is_blt,
    input  wire        i_is_bz,
    input  wire        i_is_jump_imm,
    input  wire        i_is_jump_reg,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire [15:0] o_pc_plus_2,
    output wire [15:0] o_pc_branch,
    output wire [15:0] o_pc_jalr,
    output wire [1:0]  o_pc_sel
);

    wire w_is_taken;
    wire w_cout_unused1, w_cout_unused2, w_cout_unused3;

    // アドレス計算ユニット1: 次の命令アドレス (PC + 2)
    pc_control_adder_16bit u_adder_plus_2 (
        .i_a    (i_pc),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (o_pc_plus_2),
        .o_cout (w_cout_unused1)
    );

    // アドレス計算ユニット2: 相対分岐ターゲット (PC + imm)
    // blt, bz, jal 命令で使用
    pc_control_adder_16bit u_adder_branch (
        .i_a    (i_pc),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (o_pc_branch),
        .o_cout (w_cout_unused2)
    );

    // アドレス計算ユニット3: 絶対分岐ターゲット (rs1 + imm)
    // jalr 命令で使用
    pc_control_adder_16bit u_adder_jalr (
        .i_a    (i_rs1_data),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (o_pc_jalr),
        .o_cout (w_cout_unused3)
    );

    // 条件判定ユニット: 前サイクルのフラグに基づき分岐を実行するか判定
    pc_control_condition u_condition (
        .i_is_blt   (i_is_blt),
        .i_is_bz    (i_is_bz),
        .i_flag_z   (i_flag_z),
        .i_flag_n   (i_flag_n),
        .i_flag_v   (i_flag_v),
        .o_is_taken (w_is_taken)
    );

    // 次のPC選択信号の生成
    // 00: PC + 2 (通常)
    // 01: PC + imm (分岐成立、または jal)
    // 10: rs1 + imm (jalr)
    assign o_pc_sel = (i_is_jump_reg)           ? 2'b10 :
                      (i_is_jump_imm | w_is_taken) ? 2'b01 : 2'b00;

endmodule