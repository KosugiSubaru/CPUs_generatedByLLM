module alu_core_1bit_logic (
    input  wire       i_a,
    input  wire       i_b,
    input  wire [2:0] i_op, // オペコードの下位3ビット (AND:010, OR:011, XOR:100, NOT:101)
    output wire       o_data
);

    wire w_and;
    wire w_or;
    wire w_xor;
    wire w_not;

    // 各論理演算を個別の配線として定義
    // 論理合成後の回路図において、4つの基本ゲートが並列に配置される様子を視覚化
    assign w_and = i_a & i_b;
    assign w_or  = i_a | i_b;
    assign w_xor = i_a ^ i_b;
    assign w_not = ~i_a;

    // 命令選択信号(i_op)に基づき、最終的な1ビット出力を選択
    assign o_data = (i_op == 3'b010) ? w_and :
                    (i_op == 3'b011) ? w_or  :
                    (i_op == 3'b100) ? w_xor :
                    (i_op == 3'b101) ? w_not : 1'b0;

endmodule