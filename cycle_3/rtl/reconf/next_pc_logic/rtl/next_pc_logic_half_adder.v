module next_pc_logic_half_adder (
    input  wire i_a,
    input  wire i_b,
    output wire o_sum,
    output wire o_cout
);

    // 半加算器の論理回路構成
    // 和(Sum)は入力ビットの排他的論理和(XOR)
    assign o_sum  = i_a ^ i_b;

    // 桁上げ(Carry out)は入力ビットの論理積(AND)
    assign o_cout = i_a & i_b;

endmodule