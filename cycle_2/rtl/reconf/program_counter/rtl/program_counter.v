module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_imm,        // 符号拡張済み即値
    input  wire [15:0] i_rs1_data,   // jalr命令用ベースアドレス
    input  wire [1:0]  i_pc_sel,     // 次PC選択信号 (00:通常, 01:相対分岐, 10:絶対分岐, 11:リセット)
    output wire [15:0] o_pc,         // 命令メモリ用アドレス
    output wire [15:0] o_pc_plus_2   // jal/jalr用戻りアドレス (rd書き込み用)
);

    // 内部ワイヤ定義
    wire [15:0] w_pc_current;
    wire [15:0] w_pc_next;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_pc_relative;
    wire [15:0] w_pc_absolute;

    // --- 1. 状態保持部 (Register) ---
    // 現在実行中の命令アドレスをクロック同期で保持
    program_counter_register_16bit u_reg_16bit (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_pc_next),
        .o_q     (w_pc_current)
    );

    // --- 2. アドレス計算部 (Adders) ---
    
    // 通常増分: PC + 2
    program_counter_adder_16bit u_adder_seq (
        .i_a   (w_pc_current),
        .i_b   (16'h0002),
        .o_sum (w_pc_plus_2)
    );

    // 相対分岐アドレス計算: PC + imm (blt, bz, jal用)
    program_counter_adder_16bit u_adder_rel (
        .i_a   (w_pc_current),
        .i_b   (i_imm),
        .o_sum (w_pc_relative)
    );

    // 絶対ジャンプアドレス計算: rs1 + imm (jalr用)
    program_counter_adder_16bit u_adder_abs (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_pc_absolute)
    );

    // --- 3. 次PC選択部 (MUX) ---
    // 制御ユニットからの信号(i_pc_sel)により、次にPCが取るべき値を選択
    program_counter_mux4_16bit u_mux4_16bit (
        .i_sel (i_pc_sel),
        .i_d0  (w_pc_plus_2),   // 00: Sequential
        .i_d1  (w_pc_relative), // 01: Branch / JAL
        .i_d2  (w_pc_absolute), // 10: JALR
        .i_d3  (16'h0000),      // 11: Reset Default
        .o_y   (w_pc_next)
    );

    // 外部出力への接続
    assign o_pc = w_pc_current;
    assign o_pc_plus_2 = w_pc_plus_2;

endmodule