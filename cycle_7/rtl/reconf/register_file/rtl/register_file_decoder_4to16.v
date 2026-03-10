module register_file_decoder_4to16 (
    input  wire [3:0]  i_sel,
    input  wire        i_en,
    output wire [15:0] o_out
);

    wire [3:0] w_high_en;

    // 上位2ビットをデコードして4本のイネーブル信号を作成
    register_file_decoder_2to4 u_dec_high (
        .i_sel (i_sel[3:2]),
        .i_en  (i_en),
        .o_out (w_high_en)
    );

    // 下位2ビットをデコードして合計16本の選択信号を作成
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_dec_low
            register_file_decoder_2to4 u_dec_low (
                .i_sel (i_sel[1:0]),
                .i_en  (w_high_en[i]),
                .o_out (o_out[i*4 +: 4])
            );
        end
    endgenerate

endmodule