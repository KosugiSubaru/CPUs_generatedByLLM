module data_path_mux_1bit_2to1 (
    input  wire i_sel,
    input  wire i_data0,
    input  wire i_data1,
    output wire o_q
);

    // 1ビット2対1セレクタの最小構成単位
    // 論理合成後の回路図において、特定のデータ（rs2データか即値か等）が
    // 選択される物理的な切り替え地点を視覚化するために定義
    assign o_q = (i_sel == 1'b0) ? i_data0 : i_data1;

endmodule