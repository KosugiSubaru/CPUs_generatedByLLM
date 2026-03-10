module program_counter_full_adder (
    input wire i_a,
    input wire i_b,
    input wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    wire w_xor_ab;
    wire w_and_ab;
    wire w_and_cin_xor;

    assign w_xor_ab = i_a ^ i_b;
    assign w_and_ab = i_a & i_b;
    assign w_and_cin_xor = i_cin & w_xor_ab;

    assign o_sum  = w_xor_ab ^ i_cin;
    assign o_cout = w_and_ab | w_and_cin_xor;

endmodule