module program_counter_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    wire w_sum1;
    wire w_cout1;
    wire w_cout2;

    // 1つ目の半加算器: AとBを合算
    program_counter_half_adder u_ha1 (
        .i_a    (i_a),
        .i_b    (i_b),
        .o_sum  (w_sum1),
        .o_cout (w_cout1)
    );

    // 2つ目の半加算器: A+Bの結果と前段のキャリー(cin)を合算
    program_counter_half_adder u_ha2 (
        .i_a    (w_sum1),
        .i_b    (i_cin),
        .o_sum  (o_sum),
        .o_cout (w_cout2)
    );

    // キャリーアウトの出力 (いずれかの半加算器でキャリーが発生すれば1)
    assign o_cout = w_cout1 | w_cout2;

endmodule