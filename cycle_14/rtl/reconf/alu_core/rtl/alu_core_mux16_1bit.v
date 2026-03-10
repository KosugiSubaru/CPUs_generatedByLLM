module alu_core_mux16_1bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_in,
    output wire        o_out
);

    // 16個の演算候補から、Opcode(4bit)に基づき1ビットの結果を選択
    // 論理合成後の回路図で、各演算器から最終出力へ繋がるゲートとして視覚化される
    assign o_out = i_in[i_sel];

endmodule