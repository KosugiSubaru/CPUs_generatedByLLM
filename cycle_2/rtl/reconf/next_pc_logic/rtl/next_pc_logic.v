module next_pc_logic (
    input  wire [15:0] i_pc_current,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,   // jalr命令用のベースアドレス
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    input  wire        i_is_bz,      // 命令デコード信号：bz
    input  wire        i_is_blt,     // 命令デコード信号：blt
    input  wire        i_is_jal,     // 命令デコード信号：jal
    input  wire        i_is_jalr,    // 命令デコード信号：jalr
    output wire [15:0] o_pc_next,    // 次サイクルのPC値
    output wire [15:0] o_pc_plus_2   // jal/jalr用の戻りアドレス (rd書き込み用)
);

    // 内部ワイヤ：アドレス候補
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;

    // 内部ワイヤ：選択制御
    wire        w_branch_taken;
    wire [1:0]  w_pc_sel;

    // --- 1. アドレス計算ユニット (Adders) ---
    // 通常のインクリメント計算 (PC + 2)
    next_pc_logic_adder_16bit u_adder_plus_2 (
        .i_a   (i_pc_current),
        .i_b   (16'h0002),
        .o_sum (w_pc_plus_2)
    );

    // 相対アドレス計算 (PC + imm) : blt, bz, jalで使用
    next_pc_logic_adder_16bit u_adder_relative (
        .i_a   (i_pc_current),
        .i_b   (i_imm),
        .o_sum (w_pc_plus_imm)
    );

    // 絶対アドレス計算 (rs1 + imm) : jalrで使用
    next_pc_logic_adder_16bit u_adder_absolute (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_rs1_plus_imm)
    );

    // --- 2. 分岐判定ユニット (Condition Evaluator) ---
    // フラグの状態と命令の種類を照合し、分岐の成否を判定
    next_pc_logic_cond_eval u_cond_eval (
        .i_is_bz   (i_is_bz),
        .i_is_blt  (i_is_blt),
        .i_flag_z  (i_flag_z),
        .i_flag_n  (i_flag_n),
        .i_flag_v  (i_flag_v),
        .o_taken   (w_branch_taken)
    );

    // --- 3. 選択信号生成ロジック ---
    // MUX用の選択信号を生成
    // 00: PC + 2 (Default)
    // 01: PC + imm (Relative Branch Taken or JAL)
    // 10: rs1 + imm (JALR)
    assign w_pc_sel[0] = w_branch_taken | i_is_jal;
    assign w_pc_sel[1] = i_is_jalr;

    // --- 4. 次PC選択マルチプレクサ (MUX) ---
    // 最終的な次サイクルのアドレスを1つ選択
    next_pc_logic_mux4_16bit u_mux_next_pc (
        .i_sel (w_pc_sel),
        .i_d0  (w_pc_plus_2),
        .i_d1  (w_pc_plus_imm),
        .i_d2  (w_rs1_plus_imm),
        .i_d3  (16'h0000), // 未使用（リセット/エラー用拡張領域）
        .o_y   (o_pc_next)
    );

    // 外部出力への接続
    assign o_pc_plus_2 = w_pc_plus_2;

endmodule