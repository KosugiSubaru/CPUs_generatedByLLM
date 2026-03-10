module register_file_decoder_4to16 (
    input  wire [3:0]  i_addr,
    input  wire        i_wen,
    output wire [15:0] o_wen_bus
);

    // 4ビットのアドレスと全体の書き込み許可信号(i_wen)をデコードし
    // 16本の個別書き込み許可信号に変換する。
    // 論理合成後の回路図で、各レジスタセルへの有効化パスが視覚化される。

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decode_logic
            assign o_wen_bus[i] = (i_addr == i) ? i_wen : 1'b0;
        end
    endgenerate

endmodule