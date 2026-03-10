module control_unit_decoder_2to4 (
    input  wire [1:0] i_sel,
    input  wire       i_en,
    output wire [3:0] o_out
);

    // 2ビット入力を4ビットのOne-hot信号に変換する論理構成
    // 論理合成後の回路図でゲートレベルのデコード構造を視覚化する
    assign o_out[0] = i_en & (~i_sel[1] & ~i_sel[0]);
    assign o_out[1] = i_en & (~i_sel[1] &  i_sel[0]);
    assign o_out[2] = i_en & ( i_sel[1] & ~i_sel[0]);
    assign o_out[3] = i_en & ( i_sel[1] &  i_sel[0]);

endmodule