module alu_core_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    wire w_sum1;
    wire w_carry1;
    wire w_carry2;

    // 半加算器1: AとBを合算
    alu_core_half_adder u_ha1 (
        .i_a     (i_a),
        .i_b     (i_b),
        .o_sum   (w_sum1),
        .o_carry (w_carry1)
    );

    // 半加算器2: HA1の結果とキャリーインを合算
    alu_core_half_adder u_ha2 (
        .i_a     (w_sum1),
        .i_b     (i_cin),
        .o_sum   (o_sum),
        .o_carry (w_carry2)
    );

    // 最終的なキャリーアウトの生成
    assign o_cout = w_carry1 | w_carry2;

endmodule