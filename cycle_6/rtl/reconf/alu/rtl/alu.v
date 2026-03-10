module alu (
    input  wire [3:0]  i_alu_op,
    input  wire [15:0] i_src_a,
    input  wire [15:0] i_src_b,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    // 内部ワイヤ定義
    wire [15:0] w_res_adder;
    wire [15:0] w_res_logic;
    wire [15:0] w_res_shifter;
    wire        w_v_from_adder;

    // 加減算器ユニット：add, sub, addi, load, store 用
    // i_alu_op[0] を減算切り替え信号として使用
    alu_adder_subtractor_16bit u_adder_sub (
        .i_a      (i_src_a),
        .i_b      (i_src_b),
        .i_is_sub (i_alu_op[0]),
        .o_sum    (w_res_adder),
        .o_v      (w_v_from_adder)
    );

    // 論理演算ユニット：and, or, xor, not 用
    alu_logic_unit_16bit u_logic (
        .i_a   (i_src_a),
        .i_b   (i_src_b),
        .i_op  (i_alu_op[2:0]),
        .o_y   (w_res_logic)
    );

    // シフト演算ユニット：sra, sla 用
    alu_shifter_16bit u_shifter (
        .i_a   (i_src_a),
        .i_b   (i_src_b),
        .i_op  (i_alu_op[0]),
        .o_y   (w_res_shifter)
    );

    // 結果選択セレクタ：ALUOpに基づき最終出力を決定
    alu_mux_result u_mux_res (
        .i_alu_op      (i_alu_op),
        .i_res_adder   (w_res_adder),
        .i_res_logic   (w_res_logic),
        .i_res_shifter (w_res_shifter),
        .i_imm_val     (i_src_b),
        .o_result      (o_result)
    );

    // フラグ生成ユニット：最終結果からフラグを抽出
    alu_flag_gen u_flag_gen (
        .i_result  (o_result),
        .i_v_adder (w_v_from_adder),
        .o_z       (o_flag_z),
        .o_n       (o_flag_n),
        .o_v       (o_flag_v)
    );

endmodule