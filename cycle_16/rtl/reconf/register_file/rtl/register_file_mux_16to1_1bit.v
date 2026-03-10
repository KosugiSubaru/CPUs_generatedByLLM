module register_file_mux_16to1_1bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_data, // 16個のレジスタから抽出された、同一ビット位のデータの集合
    output wire        o_q
);

    // インデックスによるビット選択
    // 論理合成ツールにより、視覚的なマルチプレクサ（MUX）ツリーとして展開される
    assign o_q = i_data[i_sel];

endmodule