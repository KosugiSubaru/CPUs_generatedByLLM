module register_file_mux_16to1_1bit (
    input  wire [15:0] i_d,
    input  wire [3:0]  i_sel,
    output wire        o_q
);

    // 16入力1ビットマルチプレクサの実装
    // 16個のレジスタから供給される同一ビット位置の集合（i_d）から、
    // アドレス信号（i_sel）に基づいて1ビットを抽出する
    assign o_q = i_d[i_sel];

endmodule