module imm_gen_ext_12to16 (
    input  wire [11:0] i_imm,
    output wire [15:0] o_imm
);

    genvar i;

    // 12ビット入力を16ビットに符号拡張
    // 下位12ビット(11:0)はそのまま接続し、上位4ビット(15:12)には符号ビット(bit 11)をコピーする
    // generate文を使用することで、論理合成後の回路図において符号ビットが各ビットへ分配される様子を視覚化する
    generate
        // 下位12ビットの接続
        for (i = 0; i < 12; i = i + 1) begin : gen_lower
            assign o_imm[i] = i_imm[i];
        end
        // 上位4ビットへの符号拡張
        for (i = 12; i < 16; i = i + 1) begin : gen_sign_ext
            assign o_imm[i] = i_imm[11];
        end
    endgenerate

endmodule