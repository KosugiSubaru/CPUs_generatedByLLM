module control_unit_decoder_2to4 (
    input  wire [1:0] i_in,
    input  wire       i_en,
    output wire [3:0] o_out
);

    // 2ビット入力を4本の有効信号へデコードする基本論理
    // i_enが1の時のみ、i_inに対応するビットが1になる
    assign o_out[0] = i_en & (i_in == 2'b00);
    assign o_out[1] = i_en & (i_in == 2'b01);
    assign o_out[2] = i_en & (i_in == 2'b10);
    assign o_out[3] = i_en & (i_in == 2'b11);

endmodule