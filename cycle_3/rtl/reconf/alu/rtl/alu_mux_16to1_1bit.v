module alu_mux_16to1_1bit (
    input  wire [15:0] i_d,
    input  wire [3:0]  i_sel,
    output wire        o_q
);

    // 16入力1ビットマルチプレクサ
    // 選択信号 (i_sel) に基づいて、16個の演算候補パスの同一ビット位置から1ビットを抽出する
    // 組み合わせ回路による演算結果の最終選択段の最小単位
    assign o_q = i_d[i_sel];

endmodule