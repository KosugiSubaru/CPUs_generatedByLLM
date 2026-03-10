module alu_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    wire w_sum1;
    wire w_cout1;
    wire w_cout2;

    // 1つ目の半加算器でAとBの和を計算
    alu_half_adder u_ha1 (
        .i_a    (i_a),
        .i_b    (i_b),
        .o_sum  (w_sum1),
        .o_cout (w_cout1)
    );

    // 2つ目の半加算器で、A+Bの結果と前段からのキャリー(cin)を合算
    alu_half_adder u_ha2 (
        .i_a    (w_sum1),
        .i_b    (i_cin),
        .o_sum  (o_sum),
        .o_cout (w_cout2)
    );

    // いずれかの半加算器でキャリーが発生すれば、上位ビットへキャリーを出力
    assign o_cout = w_cout1 | w_cout2;

endmodule