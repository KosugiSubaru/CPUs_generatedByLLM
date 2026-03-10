module imm_gen_ext_8to16 (
    input  wire [7:0]  i_imm,
    output wire [15:0] o_imm
);

    genvar i;

    // 8ビット入力を16ビットに符号拡張
    // 下位8ビットはそのまま接続、上位8ビット(bit 15:8)には符号ビット(bit 7)をコピー
    generate
        // 下位ビットの接続
        for (i = 0; i < 8; i = i + 1) begin : gen_lower
            assign o_imm[i] = i_imm[i];
        end
        // 上位ビットへの符号拡張
        for (i = 8; i < 16; i = i + 1) begin : gen_sign_ext
            assign o_imm[i] = i_imm[7];
        end
    endgenerate

endmodule