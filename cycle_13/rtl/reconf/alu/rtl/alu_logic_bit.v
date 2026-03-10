module alu_logic_bit (
    input  wire i_a,
    input  wire i_b,
    output wire o_and,
    output wire o_or,
    output wire o_xor,
    output wire o_not
);

    assign o_and = i_a & i_b;
    assign o_or  = i_a | i_b;
    assign o_xor = i_a ^ i_b;
    assign o_not = ~i_a;

endmodule