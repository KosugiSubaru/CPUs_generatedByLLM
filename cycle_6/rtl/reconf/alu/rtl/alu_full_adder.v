module alu_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    // 1ビット全加算器の論理式
    // 和 (Sum): A XOR B XOR Cin
    assign o_sum  = i_a ^ i_b ^ i_cin;

    // キャリー出力 (Cout): (A AND B) OR (B AND Cin) OR (Cin AND A)
    assign o_cout = (i_a & i_b) | (i_b & i_cin) | (i_cin & i_a);

endmodule