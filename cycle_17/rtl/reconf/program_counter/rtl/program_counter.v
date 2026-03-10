module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_jump_en,   // 分岐成立またはジャンプ命令時にHigh
    input  wire        i_jalr_en,   // JALR命令時にHigh
    input  wire [15:0] i_rs1_data,  // JALR用レジスタ値
    input  wire [15:0] i_imm,       // 符号拡張済み即値（オフセット）
    output wire [15:0] o_pc,        // 命令メモリ(imem)へのアドレス
    output wire [15:0] o_pc_plus_2  // rdへの書き戻し用(Link値)
);

    wire [15:0] w_pc_current;
    wire [15:0] w_pc_next;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_base;
    wire [15:0] w_target;
    wire        w_unused_cout1;
    wire        w_unused_cout2;

    // 1. PCレジスタ本体
    program_counter_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_data  (w_pc_next),
        .o_data  (w_pc_current)
    );

    // 2. インクリメンタ (PC + 2)
    program_counter_adder_16bit u_adder_plus2 (
        .i_a    (w_pc_current),
        .i_b    (16'd2),
        .i_cin  (1'b0),
        .o_sum  (w_pc_plus_2),
        .o_cout (w_unused_cout1)
    );

    // 3. ジャンプベースアドレス選択 (PC or rs1)
    program_counter_mux2_16bit u_mux_base (
        .i_sel (i_jalr_en),
        .i_d0  (w_pc_current),
        .i_d1  (i_rs1_data),
        .o_y   (w_base)
    );

    // 4. ジャンプ先アドレス計算 (Base + imm)
    program_counter_adder_16bit u_adder_target (
        .i_a    (w_base),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_target),
        .o_cout (w_unused_cout2)
    );

    // 5. 次サイクルPC選択 (PC+2 or Target)
    program_counter_mux2_16bit u_mux_next (
        .i_sel (i_jump_en),
        .i_d0  (w_pc_plus_2),
        .i_d1  (w_target),
        .o_y   (w_pc_next)
    );

    assign o_pc        = w_pc_current;
    assign o_pc_plus_2 = w_pc_plus_2;

endmodule