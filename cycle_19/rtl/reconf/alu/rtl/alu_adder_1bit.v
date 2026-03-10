module alu_adder_1bit (
    input  wire i_a,    // 入力A
    input  wire i_b,    // 入力B
    input  wire i_cin,  // 下位からの桁上げ
    output wire o_sum,  // 加算結果
    output wire o_cout  // 上位への桁上げ
);

    // 1ビット全加算器の論理式
    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_b & i_cin) | (i_cin & i_a);

endmodule