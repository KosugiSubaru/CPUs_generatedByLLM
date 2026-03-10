module pc_adder_half (
    input  wire i_a,     // 入力A
    input  wire i_b,     // 入力B
    output wire o_sum,   // 加算結果（1ビット）
    output wire o_carry  // 桁上げ
);

    // 半加算器の論理回路構成
    assign o_sum   = i_a ^ i_b;
    assign o_carry = i_a & i_b;

endmodule