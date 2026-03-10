module next_pc_logic_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    // 1ビット全加算器の論理回路構成
    // アドレス計算用加算器を構成する最小単位の論理モジュール
    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_cin & (i_a ^ i_b));

endmodule