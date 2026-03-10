module alu (
    input  wire [15:0] i_a,      // 演算入力A (rs1)
    input  wire [15:0] i_b,      // 演算入力B (rs2 または imm)
    input  wire [15:0] i_imm,    // 即値データ (loadi用)
    input  wire [3:0]  i_alu_op, // ALU演算種別信号
    output wire [15:0] o_res,    // 演算結果
    output wire        o_flag_z, // ゼロフラグ
    output wire        o_flag_n, // ネガティブフラグ
    output wire        o_flag_v  // オーバーフローフラグ
);

    // 各演算ユニットからの結果受信用ワイヤ
    wire [15:0] w_arith_res;
    wire [15:0] w_logic_res;
    wire [15:0] w_shift_res;
    
    // 算術演算ユニットからのフラグ受信用
    wire        w_flag_n_arith;
    wire        w_flag_v_arith;

    // 減算判定 (opcode 0001)
    wire        w_is_sub;
    assign w_is_sub = (i_alu_op == 4'b0001);

    // 各サブモジュールのインスタンス化
    generate
        // 算術演算ユニット (加減算)
        alu_arithmetic u_alu_arithmetic (
            .i_a      (i_a),
            .i_b      (i_b),
            .i_sub    (w_is_sub),
            .o_res    (w_arith_res),
            .o_flag_n (w_flag_n_arith),
            .o_flag_v (w_flag_v_arith)
        );

        // 論理演算ユニット (AND, OR, XOR, NOT)
        alu_logic_16bit u_alu_logic_16bit (
            .i_a      (i_a),
            .i_b      (i_b),
            .i_alu_op (i_alu_op),
            .o_res    (w_logic_res)
        );

        // シフト演算ユニット (SRA, SLA)
        alu_shifter u_alu_shifter (
            .i_a      (i_a),
            .i_b      (i_b),
            .i_alu_op (i_alu_op),
            .o_res    (w_shift_res)
        );

        // 最終結果選択マルチプレクサ
        alu_mux u_alu_mux (
            .i_alu_op    (i_alu_op),
            .i_arith_res (w_arith_res),
            .i_logic_res (w_logic_res),
            .i_shift_res (w_shift_res),
            .i_imm       (i_imm),
            .o_res       (o_res)
        );
    endgenerate

    // フラグ出力の確定
    // Zフラグ: 全ビットが0の時に1
    assign o_flag_z = (o_res == 16'h0000);

    // Nフラグ: 結果の最上位ビット（符号ビット）
    assign o_flag_n = o_res[15];

    // Vフラグ: 算術演算ユニットから出力された値を採用（加減算時のみ有効）
    assign o_flag_v = w_flag_v_arith;

endmodule