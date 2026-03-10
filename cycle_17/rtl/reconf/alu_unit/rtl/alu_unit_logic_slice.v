module alu_unit_logic_slice (
    input  wire i_a,
    input  wire i_b,
    output wire o_and,
    output wire o_or,
    output wire o_xor,
    output wire o_not
);

    // 1ビット単位の論理演算。
    // NOTは rs1 (i_a) を対象とする。
    assign o_and = i_a & i_b;
    assign o_or  = i_a | i_b;
    assign o_xor = i_a ^ i_b;
    assign o_not = ~i_a;

endmodule