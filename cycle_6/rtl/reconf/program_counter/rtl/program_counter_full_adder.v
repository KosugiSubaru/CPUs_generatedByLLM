module program_counter_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    // 1ビット全加算器の論理回路構成
    // Sum = A ^ B ^ Cin
    assign o_sum  = i_a ^ i_b ^ i_cin;

    // Cout = (A & B) | (B & Cin) | (Cin & A)
    assign o_cout = (i_a & i_b) | (i_b & i_cin) | (i_cin & i_a);

endmodule