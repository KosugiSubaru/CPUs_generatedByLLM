module alu_half_adder (
    input  wire i_a,
    input  wire i_b,
    output wire o_sum,
    output wire o_carry
);

    // 半加算器の最小単位の論理構成
    // 論理合成後の回路図において、XORゲートとANDゲートの対として視覚化される
    assign o_sum   = i_a ^ i_b;
    assign o_carry = i_a & i_b;

endmodule