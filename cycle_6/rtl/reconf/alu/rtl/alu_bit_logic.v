module alu_bit_logic (
    input  wire       i_a,
    input  wire       i_b,
    input  wire [2:0] i_op,
    output wire       o_y
);

    // ビット単位の論理演算。alu_op[2:0] の値に応じて出力を選択
    // 010: AND, 011: OR, 100: XOR, 101: NOT
    assign o_y = (i_op == 3'b010) ? (i_a & i_b) :
                 (i_op == 3'b011) ? (i_a | i_b) :
                 (i_op == 3'b100) ? (i_a ^ i_b) :
                 (i_op == 3'b101) ? (~i_a)      :
                 1'b0;

endmodule