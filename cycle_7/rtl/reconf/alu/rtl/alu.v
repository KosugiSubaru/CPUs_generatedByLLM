module alu (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_alu_op,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_add_sub_res;
    wire        w_cout;
    wire [15:0] w_and_res;
    wire [15:0] w_or_res;
    wire [15:0] w_xor_res;
    wire [15:0] w_not_res;
    wire [15:0] w_sra_res;
    wire [15:0] w_sla_res;
    wire        w_sub_en;
    wire        w_v_add;
    wire        w_v_sub;

    // 減算命令(0001)の判定
    assign w_sub_en = (i_alu_op == 4'b0001);

    // 算術演算ブロック (加算・減算)
    alu_adder_subtractor_16bit u_arith (
        .i_a      (i_a),
        .i_b      (i_b),
        .i_sub_en (w_sub_en),
        .o_sum    (w_add_sub_res),
        .o_cout   (w_cout)
    );

    // 論理演算ブロック (AND, OR, XOR, NOT)
    alu_logic_unit_16bit u_logic (
        .i_a   (i_a),
        .i_b   (i_b),
        .o_and (w_and_res),
        .o_or  (w_or_res),
        .o_xor (w_xor_res),
        .o_not (w_not_res)
    );

    // シフト演算ブロック (SRA, SLA)
    alu_shifter_16bit u_shift (
        .i_a   (i_a),
        .i_b   (i_b[3:0]),
        .o_sra (w_sra_res),
        .o_sla (w_sla_res)
    );

    // 最終演算結果の選択 (Opcodeの下位3ビットを使用)
    // 000:add, 001:sub, 010:and, 011:or, 100:xor, 101:not, 110:sra, 111:sla
    alu_mux_8to1_16bit u_mux (
        .i_sel (i_alu_op[2:0]),
        .i_in0 (w_add_sub_res),
        .i_in1 (w_add_sub_res),
        .i_in2 (w_and_res),
        .i_in3 (w_or_res),
        .i_in4 (w_xor_res),
        .i_in5 (w_not_res),
        .i_in6 (w_sra_res),
        .i_in7 (w_sla_res),
        .o_out (o_result)
    );

    // ステータスフラグ生成
    assign o_flag_z = (o_result == 16'd0);
    assign o_flag_n = o_result[15];

    // オーバーフローフラグ(V)の計算 (ISA定義に基づく)
    // 加算：同じ符号の入力を足して結果の符号が変わった場合
    assign w_v_add = (i_a[15] == i_b[15]) && (o_result[15] != i_a[15]);
    // 減算：異なる符号の入力を引いて結果の符号が引かれる数と異なる場合
    assign w_v_sub = (i_a[15] != i_b[15]) && (o_result[15] != i_a[15]);
    
    assign o_flag_v = w_sub_en ? w_v_sub : w_v_add;

endmodule