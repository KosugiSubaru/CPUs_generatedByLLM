module control_unit_decoder_2to4 (
    input  wire       i_en,
    input  wire [1:0] i_in,
    output wire [3:0] o_out
);

    // 2ビット入力をデコードし、4ビットのうち1本を選択する論理回路
    // i_enが0の場合はすべての出力を0にする
    assign o_out[0] = i_en & (~i_in[1]) & (~i_in[0]);
    assign o_out[1] = i_en & (~i_in[1]) & ( i_in[0]);
    assign o_out[2] = i_en & ( i_in[1]) & (~i_in[0]);
    assign o_out[3] = i_en & ( i_in[1]) & ( i_in[0]);

endmodule