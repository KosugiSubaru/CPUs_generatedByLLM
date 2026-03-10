module alu_logical_bit (
    input  wire       i_a,
    input  wire       i_b,
    input  wire [2:0] i_op,
    output wire       o_res
);

    wire w_and;
    wire w_or;
    wire w_xor;
    wire w_not;

    // ビットごとの基本論理演算
    assign w_and = i_a & i_b;
    assign w_or  = i_a | i_b;
    assign w_xor = i_a ^ i_b;
    assign w_not = ~i_a;

    // Opcode[2:0]に基づいた出力の選択
    // 010: AND, 011: OR, 100: XOR, 101: NOT
    assign o_res = (i_op == 3'b010) ? w_and :
                   (i_op == 3'b011) ? w_or  :
                   (i_op == 3'b100) ? w_xor :
                   (i_op == 3'b101) ? w_not :
                   1'b0;

endmodule