module pc_calc (
    input  wire [15:0] i_pc,
    input  wire [15:0] i_pc_plus_2,
    input  wire [15:0] i_rs1_data,
    input  wire [15:0] i_imm,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    input  wire        i_branch_bz,
    input  wire        i_branch_blt,
    input  wire        i_jump,
    input  wire        i_jump_reg,
    output wire [15:0] o_next_pc
);

    wire        w_condition_met;
    wire        w_branch_taken;
    wire [15:0] w_base_addr;
    wire [15:0] w_target_addr;

    // 分岐条件判定ユニット: 保存されたフラグと命令から分岐の成否を判定
    pc_calc_branch_logic u_branch_logic (
        .i_flag_z       (i_flag_z),
        .i_flag_n       (i_flag_n),
        .i_flag_v       (i_flag_v),
        .i_branch_bz    (i_branch_bz),
        .i_branch_blt   (i_branch_blt),
        .o_condition_met(w_condition_met)
    );

    // 分岐成立、または無条件ジャンプ命令(JAL, JALR)である場合に有効化
    assign w_branch_taken = w_condition_met | i_jump | i_jump_reg;

    // 加算ベースアドレスの選択 (JALR命令ならrs1, それ以外は現在PC)
    pc_calc_mux_2to1_16bit u_mux_base (
        .i_data0 (i_pc),
        .i_data1 (i_rs1_data),
        .i_sel   (i_jump_reg),
        .o_data  (w_base_addr)
    );

    // ターゲットアドレス計算 (Base + Imm)
    pc_calc_adder_16bit u_adder_target (
        .i_a     (w_base_addr),
        .i_b     (i_imm),
        .o_sum    (w_target_addr)
    );

    // 次のPC値の最終選択 (分岐・ジャンプ成立ならTarget, 不成立ならPC+2)
    pc_calc_mux_2to1_16bit u_mux_next_pc (
        .i_data0 (i_pc_plus_2),
        .i_data1 (w_target_addr),
        .i_sel   (w_branch_taken),
        .o_data  (o_next_pc)
    );

endmodule