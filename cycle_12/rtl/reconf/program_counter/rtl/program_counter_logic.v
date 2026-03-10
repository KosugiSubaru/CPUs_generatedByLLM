module program_counter_logic (
    input  wire [15:0] i_pc_now,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire        i_pc_target_sel,  // 0: PC+imm (Branch/JAL), 1: rs1+imm (JALR)
    input  wire        i_pc_jump_taken,  // 0: PC+2, 1: Jump/Branch Target
    output wire [15:0] o_next_pc,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;
    wire [15:0] w_jump_target;
    wire        w_unused_cout1;
    wire        w_unused_cout2;
    wire        w_unused_cout3;

    // PC + 2 の計算
    program_counter_adder_16bit u_adder_plus_2 (
        .i_a    (i_pc_now),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (o_pc_plus_2),
        .o_cout (w_unused_cout1)
    );

    // PC + imm の計算 (Branch / JAL)
    program_counter_adder_16bit u_adder_pc_imm (
        .i_a    (i_pc_now),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_pc_plus_imm),
        .o_cout (w_unused_cout2)
    );

    // rs1 + imm の計算 (JALR)
    program_counter_adder_16bit u_adder_rs1_imm (
        .i_a    (i_rs1_data),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_rs1_plus_imm),
        .o_cout (w_unused_cout3)
    );

    // ジャンプ先アドレスの選択
    program_counter_mux_2to1_16bit u_mux_target (
        .i_sel  (i_pc_target_sel),
        .i_d0   (w_pc_plus_imm),
        .i_d1   (w_rs1_plus_imm),
        .o_data (w_jump_target)
    );

    // 次のPC値の最終選択 (通常インクリメントかジャンプ・分岐か)
    program_counter_mux_2to1_16bit u_mux_final (
        .i_sel  (i_pc_jump_taken),
        .i_d0   (o_pc_plus_2),
        .i_d1   (w_jump_target),
        .o_data (o_next_pc)
    );

endmodule