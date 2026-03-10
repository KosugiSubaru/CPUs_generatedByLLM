module next_pc_logic_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    // 1ビット全加算器の標準的な論理構成
    // Sum = A ^ B ^ Cin
    assign o_sum  = i_a ^ i_b ^ i_cin;

    // Cout = (A & B) | (Cin & (A ^ B))
    assign o_cout = (i_a & i_b) | (i_cin & (i_a ^ i_b));

endmodule