module alu_logic_cell (
    input  wire [3:0] i_op,
    input  wire       i_a,
    input  wire       i_b,
    output wire       o_out
);

    wire w_and;
    wire w_or;
    wire w_xor;
    wire w_not;

    assign w_and = i_a & i_b;
    assign w_or  = i_a | i_b;
    assign w_xor = i_a ^ i_b;
    assign w_not = ~i_a;

    assign o_out = (i_op == 4'b0010) ? w_and :
                   (i_op == 4'b0011) ? w_or  :
                   (i_op == 4'b0100) ? w_xor :
                   (i_op == 4'b0101) ? w_not : 1'b0;

endmodule