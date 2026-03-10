module alu (
    input  wire [3:0]  i_alu_mode,     // 制御ユニットからの演算選択信号
    input  wire [15:0] i_src1,         // 演算入力A (rs1)
    input  wire [15:0] i_src2,         // 演算入力B (rs2 または 即値)
    output wire [15:0] o_result,       // 演算結果
    output wire        o_flag_z,       // ゼロフラグ
    output wire        o_flag_n,       // 負フラグ
    output wire        o_flag_v        // オーバーフローフラグ
);

    // 内部接続用ワイヤ
    wire [15:0] w_res_arith;
    wire [15:0] w_res_logic;
    wire [15:0] w_res_shift;
    wire        w_flag_v_arith;

    // -------------------------------------------------------------------------
    // 1. 算術演算ユニット (加算・減算)
    // -------------------------------------------------------------------------
    alu_arithmetic u_arithmetic (
        .i_a      (i_src1),
        .i_b      (i_src2),
        .i_mode   (i_alu_mode[0]),     // 0:加算, 1:減算
        .o_res    (w_res_arith),
        .o_flag_v (w_flag_v_arith)
    );

    // -------------------------------------------------------------------------
    // 2. 論理演算ユニット (AND, OR, XOR, NOT)
    // -------------------------------------------------------------------------
    alu_logical u_logical (
        .i_a      (i_src1),
        .i_b      (i_src2),
        .i_mode   (i_alu_mode[2:0]),
        .o_res    (w_res_logic)
    );

    // -------------------------------------------------------------------------
    // 3. シフト演算ユニット (SRA, SLA)
    // -------------------------------------------------------------------------
    alu_shifter u_shifter (
        .i_a      (i_src1),
        .i_b      (i_src2),
        .i_mode   (i_alu_mode[0]),     // 0:右シフト, 1:左シフト
        .o_res    (w_res_shift)
    );

    // -------------------------------------------------------------------------
    // 4. 結果選択マルチプレクサ
    // -------------------------------------------------------------------------
    alu_mux_result u_mux_result (
        .i_res_arith (w_res_arith),
        .i_res_logic (w_res_logic),
        .i_res_shift (w_res_shift),
        .i_mode      (i_alu_mode),
        .o_res       (o_result)
    );

    // -------------------------------------------------------------------------
    // 5. フラグ生成ロジック
    // -------------------------------------------------------------------------
    
    // ゼロフラグ判定
    alu_flag_z_calc u_flag_z_calc (
        .i_res (o_result),
        .o_z   (o_flag_z)
    );

    // 負フラグ: 結果の最上位ビット(符号ビット)
    assign o_flag_n = o_result[15];

    // オーバーフローフラグ: 算術演算ユニットからの出力をそのまま使用
    assign o_flag_v = w_flag_v_arith;

endmodule