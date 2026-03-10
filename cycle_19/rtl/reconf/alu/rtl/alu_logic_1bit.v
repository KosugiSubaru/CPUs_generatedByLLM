module alu_logic_1bit (
    input  wire       i_a,      // 入力A
    input  wire       i_b,      // 入力B
    input  wire [3:0] i_alu_op, // ALU演算種別信号
    output wire       o_res     // 演算結果
);

    // 論理演算命令のデコード結果に基づく選択
    // AND: 0010, OR: 0011, XOR: 0100, NOT: 0101
    assign o_res = (i_alu_op == 4'b0010) ? (i_a & i_b) :
                   (i_alu_op == 4'b0011) ? (i_a | i_b) :
                   (i_alu_op == 4'b0100) ? (i_a ^ i_b) :
                   (i_alu_op == 4'b0101) ? (~i_a)      :
                   1'b0;

endmodule