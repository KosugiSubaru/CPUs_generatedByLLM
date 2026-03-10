module alu_core_flag_calc (
    input  wire [15:0] i_res,   // ALUの最終演算結果
    input  wire        i_v,     // 算術演算器からのオーバーフロー信号
    output wire        o_z,     // ゼロフラグ
    output wire        o_n,     // ネガティブフラグ
    output wire        o_v      // オーバーフローフラグ
);

    wire [15:0] w_res_bits;

    // 1. Negative Flag (N)
    // 演算結果の最上位ビット(MSB)が1であれば負数と判定
    assign o_n = i_res[15];

    // 2. Overflow Flag (V)
    // 算術演算ユニットで算出されたオーバーフロー状態をそのまま出力
    assign o_v = i_v;

    // 3. Zero Flag (Z)
    // 全ビットが0であることを判定する構造
    // 回路図上で全ビットからORゲートに入力される様子を視覚化するため、
    // ビットをワイヤに展開してリダクション演算を行う
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_z_bits
            assign w_res_bits[i] = i_res[i];
        end
    endgenerate

    // 全ビットの論理和(OR)をとり、その否定をZeroフラグとする
    assign o_z = ~(|w_res_bits);

endmodule