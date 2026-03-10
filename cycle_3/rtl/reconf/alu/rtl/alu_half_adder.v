module alu_half_adder (
    input  wire i_a,
    input  wire i_b,
    output wire o_sum,
    output wire o_cout
);

    // 半加算器の基本論理
    // 和(Sum)は入力の排他的論理和(XOR)
    assign o_sum  = i_a ^ i_b;

    // 桁上げ(Carry out)は入力の論理積(AND)
    assign o_cout = i_a & i_b;

endmodule