module pc_control_unit (
    input  wire [15:0] i_pc_now,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire        i_pc_target_sel,  // 0: PC+imm, 1: rs1+imm
    input  wire        i_pc_jump_taken,  // 0: PC+2, 1: Calculated Target
    output wire [15:0] o_next_pc,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;
    wire [15:0] w_jump_target;
    wire        w_unused_cout1;
    wire        w_unused_cout2;
    wire        w_unused_cout3;

    // 1. 次のシーケンシャルアドレス (PC + 2) の計算
    pc_control_unit_adder_16bit u_adder_seq (
        .i_a    (i_pc_now),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (o_pc_plus_2),
        .o_cout (w_unused_cout1)
    );

    // 2. PC相対ジャンプ先 (PC + imm) の計算
    pc_control_unit_adder_16bit u_adder_rel (
        .i_a    (i_pc_now),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_pc_plus_imm),
        .o_cout (w_unused_cout2)
    );

    // 3. レジスタ相対ジャンプ先 (rs1 + imm) の計算
    pc_control_unit_adder_16bit u_adder_abs (
        .i_a    (i_rs1_data),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_rs1_plus_imm),
        .o_cout (w_unused_cout3)
    );

    // 4. ジャンプ先ターゲットの選択 (PC相対 か レジスタ相対)
    pc_control_unit_mux_2to1_16bit u_mux_target (
        .i_sel  (i_pc_target_sel),
        .i_d0   (w_pc_plus_imm),
        .i_d1   (w_rs1_plus_imm),
        .o_data (w_jump_target)
    );

    // 5. 最終的な次サイクルPCの選択 (PC+2 か 計算されたジャンプ先)
    pc_control_unit_mux_2to1_16bit u_mux_final (
        .i_sel  (i_pc_jump_taken),
        .i_d0   (o_pc_plus_2),
        .i_d1   (w_jump_target),
        .o_data (o_next_pc)
    );

endmodule