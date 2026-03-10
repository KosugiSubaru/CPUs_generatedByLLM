module imm_gen_ext_4to16 (
    input  wire [3:0]  i_imm,
    output wire [15:0] o_imm
);

    genvar i;

    // 下位4ビットの接続と上位12ビットの符号拡張を構造的に記述
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_ext
            if (i < 4) begin : bit_pass
                // 下位ビットはそのまま接続
                assign o_imm[i] = i_imm[i];
            end else begin : bit_sign_ext
                // 上位ビットは入力の最上位ビット（符号ビット）をコピー
                assign o_imm[i] = i_imm[3];
            end
        end
    endgenerate

endmodule