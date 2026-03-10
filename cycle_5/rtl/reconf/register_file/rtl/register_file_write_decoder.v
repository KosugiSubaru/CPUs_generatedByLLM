module register_file_write_decoder (
    input  wire [3:0]  i_addr,     // 書き込み先レジスタ番号
    input  wire        i_wen,      // レジスタ書き込み有効信号
    output wire [15:0] o_enables   // 各レジスタセルへの書き込み許可信号
);

    genvar i;

    // 4ビットのアドレスを16本のデコード信号に変換
    // RegWrite(i_wen)信号と論理積をとることで、最終的な許可信号を生成
    // 論理合成後の回路図で、16個の同じ判定回路が並ぶパターン構造を形成する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_write_en
            assign o_enables[i] = i_wen & (i_addr == i);
        end
    endgenerate

endmodule