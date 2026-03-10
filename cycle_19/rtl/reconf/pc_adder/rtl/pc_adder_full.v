module pc_adder_full (
    input  wire i_a,      // 入力A
    input  wire i_b,      // 入力B
    input  wire i_cin,    // 下位からの桁上げ
    output wire o_sum,    // 加算結果
    output wire o_cout    // 上位への桁上げ
);

    wire w_sum1;
    wire w_carry1;
    wire w_carry2;

    // 半加算器1: AとBを合算
    pc_adder_half u_half1 (
        .i_a     (i_a),
        .i_b     (i_b),
        .o_sum   (w_sum1),
        .o_carry (w_carry1)
    );

    // 半加算器2: 合算結果と下位からの桁上げを合算
    pc_adder_half u_half2 (
        .i_a     (w_sum1),
        .i_b     (i_cin),
        .o_sum   (o_sum),
        .o_carry (w_carry2)
    );

    // 二つの半加算器のいずれかで桁上げが発生すれば上位へ送る
    assign o_cout = w_carry1 | w_carry2;

endmodule