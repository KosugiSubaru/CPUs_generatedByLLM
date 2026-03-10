module next_pc_logic_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    wire w_ha1_sum;
    wire w_ha1_cout;
    wire w_ha2_cout;

    // 1つ目の半加算器: 入力AとBを演算
    next_pc_logic_half_adder u_ha1 (
        .i_a     (i_a),
        .i_b     (i_b),
        .o_sum   (w_ha1_sum),
        .o_carry (w_ha1_cout)
    );

    // 2つ目の半加算器: 1つ目の和とキャリー入力を演算
    next_pc_logic_half_adder u_ha2 (
        .i_a     (w_ha1_sum),
        .i_b     (i_cin),
        .o_sum   (o_sum),
        .o_carry (w_ha2_cout)
    );

    // キャリー出力の論理合成（ORゲートによる統合）
    assign o_cout = w_ha1_cout | w_ha2_cout;

endmodule