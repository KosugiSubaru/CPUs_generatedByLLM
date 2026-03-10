module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,      // 00: PC+2, 01: Branch, 10: JAL, 11: JALR
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    output wire [15:0] o_pc,
    output wire [15:0] o_pc_plus_2
);

    // 内部ワイヤ定義
    wire [15:0] w_current_pc;
    wire [15:0] w_next_pc;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_pc_target;
    wire [15:0] w_target_base;
    wire        w_cout_inc;
    wire        w_cout_target;

    // 現在のPCを保持するレジスタ
    program_counter_register_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_next_pc),
        .o_q     (w_current_pc)
    );

    // 次の命令アドレス (PC + 2) の計算
    program_counter_adder_16bit u_adder_inc (
        .i_a     (w_current_pc),
        .i_b     (16'h0002),
        .i_cin   (1'b0),
        .o_sum   (w_pc_plus_2),
        .o_cout  (w_cout_inc)
    );

    // ジャンプ/分岐先アドレスの計算基点を選択
    // JALR (2'b11) の時のみ rs1 を選択、それ以外 (Branch/JAL) は PC を基点とする
    assign w_target_base = (i_pc_sel == 2'b11) ? i_rs1_data : w_current_pc;

    // ジャンプ/分岐先アドレスの計算 (w_target_base + i_imm)
    program_counter_adder_16bit u_adder_target (
        .i_a     (w_target_base),
        .i_b     (i_imm),
        .i_cin   (1'b0),
        .o_sum   (w_pc_target),
        .o_cout  (w_cout_target)
    );

    // 次のPC値の選択
    // 00: 通常進捗 (PC+2)
    // 01: 分岐ターゲット (PC+imm)
    // 10: JALターゲット (PC+imm)
    // 11: JALRターゲット (rs1+imm)
    program_counter_mux_4to1_16bit u_pc_mux (
        .i_sel (i_pc_sel),
        .i_d0  (w_pc_plus_2),
        .i_d1  (w_pc_target),
        .i_d2  (w_pc_target),
        .i_d3  (w_pc_target),
        .o_y   (w_next_pc)
    );

    // 外部出力への接続
    assign o_pc = w_current_pc;
    assign o_pc_plus_2 = w_pc_plus_2;

endmodule