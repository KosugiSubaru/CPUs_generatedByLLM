module pc_selector (
    input  wire [15:0] i_pc_current,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    input  wire        i_branch_en,
    input  wire        i_branch_type,
    input  wire        i_jump_en,
    input  wire        i_jalr_sel,
    output wire [15:0] o_pc_next,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_pc_plus_2;
    wire [15:0] w_base_addr;
    wire [15:0] w_target_addr;
    wire        w_branch_taken;
    wire        w_sel_pc_target;
    wire        w_unused_cout1;
    wire        w_unused_cout2;

    assign o_pc_plus_2 = w_pc_plus_2;
    assign w_sel_pc_target = i_jump_en | w_branch_taken;

    // PC + 2 計算ユニット
    pc_selector_adder_16bit u_adder_pc_plus_2 (
        .i_a    (i_pc_current),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (w_pc_plus_2),
        .o_cout (w_unused_cout1)
    );

    // 条件分岐の成否判定
    pc_selector_branch_check u_branch_check (
        .i_flag_z       (i_flag_z),
        .i_flag_n       (i_flag_n),
        .i_flag_v       (i_flag_v),
        .i_branch_en    (i_branch_en),
        .i_branch_type  (i_branch_type),
        .o_branch_taken (w_branch_taken)
    );

    // ジャンプ/分岐のベースアドレス選択 (JALRならrs1, それ以外はPC)
    pc_selector_mux2_16bit u_mux_base (
        .i_sel (i_jalr_sel),
        .i_d0  (i_pc_current),
        .i_d1  (i_rs1),
        .o_q   (w_base_addr)
    );

    // ターゲットアドレス算出 (Base + Imm)
    pc_selector_adder_16bit u_adder_target (
        .i_a    (w_base_addr),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_target_addr),
        .o_cout (w_unused_cout2)
    );

    // 次サイクルのPC値を選択
    pc_selector_mux2_16bit u_mux_next_pc (
        .i_sel (w_sel_pc_target),
        .i_d0  (w_pc_plus_2),
        .i_d1  (w_target_addr),
        .o_q   (o_pc_next)
    );

endmodule