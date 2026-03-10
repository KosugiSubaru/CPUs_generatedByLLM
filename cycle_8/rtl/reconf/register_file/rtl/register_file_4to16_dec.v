module register_file_4to16_dec (
    input  wire        i_wen,
    input  wire [3:0]  i_addr,
    output wire [15:0] o_wens
);

    // 4ビットのアドレス信号を16本の独立したデコード信号に変換
    // generate文を用いることで、論理合成後の回路図において
    // 16個の独立した比較器（またはANDゲート群）として整列して視覚化される
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_dec_logic
            // アドレスが一致し、かつ全体の書き込み有効信号(i_wen)がHighの時のみ、対象ビットをHighにする
            assign o_wens[i] = (i_addr == i) & i_wen;
        end
    endgenerate

endmodule