module alu_main_logic_slice (
    input  wire [1:0] i_sel,
    input  wire       i_a,
    input  wire       i_b,
    output wire       o_q
);

    wire w_and;
    wire w_or;
    wire w_xor;
    wire w_not;

    assign w_and = i_a & i_b;
    assign w_or  = i_a | i_b;
    assign w_xor = i_a ^ i_b;
    assign w_not = ~i_a;

    // ISA定義のOpcodeビット[1:0]に基づき、適切な論理演算を選択するよう修正
    // AND: 0010 (10), OR: 0011 (11), XOR: 0100 (00), NOT: 0101 (01)
    assign o_q = (i_sel == 2'b10) ? w_and :
                 (i_sel == 2'b11) ? w_or  :
                 (i_sel == 2'b00) ? w_xor :
                                    w_not;

endmodule