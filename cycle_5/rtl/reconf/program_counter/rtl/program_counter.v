module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,      // 00: PC+2, 01: PC+imm, 10: rs1+imm
    input  wire [15:0] i_imm,         // 符号拡張済み即値
    input  wire [15:0] i_rs1_data,    // jalr用ベースアドレス
    output wire [15:0] o_pc,          // 現在のPC（命令メモリへ）
    output wire [15:0] o_pc_plus_2    // 書き戻し用（jal/jalr用）
);

    // 内部接続用ワイヤ
    wire [15:0] w_current_pc;
    wire [15:0] w_next_pc;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;

    // -------------------------------------------------------------------------
    // 1. PCレジスタのインスタンス化 (16-bit)
    // -------------------------------------------------------------------------
    program_counter_register_nbit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_next_pc),
        .o_q     (w_current_pc)
    );

    // -------------------------------------------------------------------------
    // 2. 次アドレス計算用アダーのインスタンス化
    // -------------------------------------------------------------------------
    
    // 通常歩進用 (PC + 2)
    program_counter_adder_nbit u_adder_plus_2 (
        .i_a     (w_current_pc),
        .i_b     (16'h0002),
        .o_sum   (w_pc_plus_2)
    );

    // 相対分岐・ジャンプ用 (PC + imm)
    program_counter_adder_nbit u_adder_relative (
        .i_a     (w_current_pc),
        .i_b     (i_imm),
        .o_sum   (w_pc_plus_imm)
    );

    // レジスタ間接ジャンプ用 (rs1 + imm)
    program_counter_adder_nbit u_adder_absolute (
        .i_a     (i_rs1_data),
        .i_b     (i_imm),
        .o_sum   (w_rs1_plus_imm)
    );

    // -------------------------------------------------------------------------
    // 3. 次PC選択マルチプレクサのインスタンス化
    // -------------------------------------------------------------------------
    program_counter_mux_next u_mux_next (
        .i_pc_plus_2    (w_pc_plus_2),
        .i_pc_plus_imm  (w_pc_plus_imm),
        .i_rs1_plus_imm (w_rs1_plus_imm),
        .i_sel          (i_pc_sel),
        .o_next_pc      (w_next_pc)
    );

    // -------------------------------------------------------------------------
    // 4. 出力代入
    // -------------------------------------------------------------------------
    assign o_pc = w_current_pc;
    assign o_pc_plus_2 = w_pc_plus_2;

endmodule