module control_unit_decoder_4to16 (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_dec
);

    wire [3:0] w_enable;

    // 上位2ビットをデコードして、4つの下位デコーダのうちどれを有効にするかを選択
    control_unit_decoder_2to4 u_dec_high (
        .i_en  (1'b1),
        .i_in  (i_opcode[3:2]),
        .o_out (w_enable)
    );

    // 下位2ビットをデコードして、16本のうち1本の信号をアクティブにする
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_dec_low
            control_unit_decoder_2to4 u_dec_low (
                .i_en  (w_enable[i]),
                .i_in  (i_opcode[1:0]),
                .o_out (o_dec[4*i+3 : 4*i])
            );
        end
    endgenerate

endmodule