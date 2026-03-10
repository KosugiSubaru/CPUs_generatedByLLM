module next_pc_logic_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    // 1ビット全加算器の論理構成
    // 和(Sum)の算出: AとBとキャリー入力の排他的論理和
    assign o_sum  = i_a ^ i_b ^ i_cin;

    // キャリー出力(Cout)の算出
    // AとBの両方が1、または(AとBのどちらかが1かつキャリー入力が1)の場合に発生
    assign o_cout = (i_a & i_b) | (i_cin & (i_a ^ i_b));

endmodule