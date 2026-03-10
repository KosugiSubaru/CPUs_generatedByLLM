module instruction_decoder_onehot_2to4 (
    input  wire       i_en,
    input  wire [1:0] i_bits,
    output wire [3:0] o_out
);

    // 2ビット入力を4本のOne-hot信号にデコードする基本ゲート論理
    // i_enが1の時のみ、指定されたインデックスの出力を1にする
    assign o_out[0] = i_en & (~i_bits[1] & ~i_bits[0]);
    assign o_out[1] = i_en & (~i_bits[1] &  i_bits[0]);
    assign o_out[2] = i_en & ( i_bits[1] & ~i_bits[0]);
    assign o_out[3] = i_en & ( i_bits[1] &  i_bits[0]);

endmodule