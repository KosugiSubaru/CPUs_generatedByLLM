module alu_flag_gen (
    input  wire [15:0] i_result,
    input  wire        i_v_adder,
    output wire        o_z,
    output wire        o_n,
    output wire        o_v
);

    // Zero Flag (Z): 全ビットをORして反転（リダクション演算子を使用）
    assign o_z = ~(|i_result);

    // Negative Flag (N): 演算結果の最上位ビット(15bit)をそのまま出力
    assign o_n = i_result[15];

    // Overflow Flag (V): 加減算器(alu_adder_subtractor)で計算された値を反映
    assign o_v = i_v_adder;

endmodule