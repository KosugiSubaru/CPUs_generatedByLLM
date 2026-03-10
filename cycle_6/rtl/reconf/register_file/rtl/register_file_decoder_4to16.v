module register_file_decoder_4to16 (
    input  wire [3:0]  i_addr,
    input  wire        i_en,
    output wire [15:0] o_dec
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decode_logic
            // アドレス入力がループインデックスと一致し、かつ書き込み有効(i_en)の場合のみ1を出力
            assign o_dec[i] = (i_en && (i_addr == i[3:0]));
        end
    endgenerate

endmodule