module alu_core_bit_logic (
    input  wire       i_a,
    input  wire       i_b,
    input  wire [1:0] i_op, // opcode[1:0]
    output wire       o_y
);

    // 1ビット単位の論理演算。opcode[1:0]に基づき演算を選択
    // 00: XOR, 01: NOT, 10: AND, 11: OR
    assign o_y = (i_op == 2'b10) ? (i_a & i_b) :
                 (i_op == 2'b11) ? (i_a | i_b) :
                 (i_op == 2'b00) ? (i_a ^ i_b) :
                                   (~i_a); // NOT (01)

endmodule