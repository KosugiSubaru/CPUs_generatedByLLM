module alu_core (
    input  wire [15:0] i_a,        // rs1データ
    input  wire [15:0] i_b,        // rs2データ または 即値
    input  wire [3:0]  i_alu_op,   // オペコード [3:0]
    output wire [15:0] o_result,   // 演算結果
    output wire        o_flag_z,   // Zeroフラグ
    output wire        o_flag_n,   // Negativeフラグ
    output wire        o_flag_v    // Overflowフラグ
);

    // 内部接続用ワイヤ（各演算ユニットの出力を保持）
    wire [15:0] w_arith_result;
    wire [15:0] w_logic_result;
    wire [15:0] w_shift_result;
    wire        w_arith_v;

    // --- 1. 算術演算ユニット (加減算) ---
    // オペコード 0001 (sub) の時に減算モードを有効化
    // また add(0000), addi(1000), load(1010), store(1011) も加算器を使用する
    alu_core_nbit_adder_subtractor u_arith (
        .i_a      (i_a),
        .i_b      (i_b),
        .i_sub_en (i_alu_op[0] & ~i_alu_op[3]), // 0001のみ減算
        .o_sum    (w_arith_result),
        .o_v      (w_arith_v)
    );

    // --- 2. 論理演算ユニット (AND/OR/XOR/NOT) ---
    // オペコード 0010(and), 0011(or), 0100(xor), 0101(not)
    alu_core_nbit_logic u_logic (
        .i_a    (i_a),
        .i_b    (i_b),
        .i_op   (i_alu_op[2:0]),
        .o_data (w_logic_result)
    );

    // --- 3. シフト演算ユニット (SRA/SLA) ---
    // オペコード 0110(sra), 0111(sla)
    alu_core_nbit_shifter u_shifter (
        .i_data (i_a),
        .i_amt  (i_b[3:0]), // 下位4bitをシフト量として使用
        .i_left (i_alu_op[0]), // 0111の時に左シフト
        .o_data (w_shift_result)
    );

    // --- 4. 結果選択ユニット (MUX) ---
    // 演算種別に応じて、最終的な o_result を決定
    // 命令セットの定義に基づき、算術・論理・シフト・即値パスを選択
    alu_core_nbit_result_mux u_result_mux (
        .i_sel   (i_alu_op),
        .i_arith (w_arith_result),
        .i_logic (w_logic_result),
        .i_shift (w_shift_result),
        .i_imm   (i_b),           // loadi(1001)用
        .o_q     (o_result)
    );

    // --- 5. フラグ生成 ---
    // Zeroフラグ: 16bitの結果がすべて0のとき1
    assign o_flag_z = (o_result == 16'h0000);

    // Negativeフラグ: 結果のMSB（符号ビット）が1のとき1
    assign o_flag_n = o_result[15];

    // Overflowフラグ: 加算器/減算器ユニットからの溢れ信号を出力
    // (算術演算命令 0000, 0001, 1000 等が実行されている時のみ有効)
    assign o_flag_v = w_arith_v;

endmodule