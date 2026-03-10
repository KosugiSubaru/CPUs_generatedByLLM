module alu_flag_logic (
    input  wire [15:0] i_result,
    input  wire        i_adder_v,
    input  wire [3:0]  i_alu_op,
    output wire        o_z,
    output wire        o_n,
    output wire        o_v
);

    // Negative (N) フラグ: 演算結果の最上位ビット（符号ビット）を抽出
    assign o_n = i_result[15];

    // Zero (Z) フラグ: 全ビットが0であることを判定するロジック
    // 教育的視点から、ORゲートの連鎖によるリダクション構造を可視化
    wire [16:0] w_or_chain;
    assign w_or_chain[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_zero_detect
            assign w_or_chain[i+1] = w_or_chain[i] | i_result[i];
        end
    endgenerate

    // 1ビットでも1があればw_or_chain[16]は1になるため、それを反転してo_zとする
    assign o_z = ~w_or_chain[16];

    // Overflow (V) フラグ: 加減算器モジュールで計算された値をそのまま出力
    // ALUトップにて、加減算以外の命令（論理演算等）の際はVを無視するか、
    // フラグレジスタの書き込み制御にて管理する構成とする
    assign o_v = i_adder_v;

endmodule