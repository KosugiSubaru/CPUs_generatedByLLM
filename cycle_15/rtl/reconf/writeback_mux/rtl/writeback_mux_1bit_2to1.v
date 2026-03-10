module writeback_mux_1bit_2to1 (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_data
);

    // 1ビットの2入力セレクタ
    // セレクト信号(i_sel)が1ならi_d1を、0ならi_d0を選択して出力する
    // 論理合成後の回路図において、16ビット幅の選択回路を構成する最小要素として視覚化される
    assign o_data = (i_sel == 1'b1) ? i_d1 : i_d0;

endmodule