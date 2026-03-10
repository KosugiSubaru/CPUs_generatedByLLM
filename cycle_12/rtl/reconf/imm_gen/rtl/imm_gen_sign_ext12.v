module imm_gen_sign_ext12 (
    input  wire [11:0] i_imm_12bit,
    output wire [15:0] o_imm_16bit
);

    // 下位12ビットをそのまま出力し、上位ビットを入力の符号ビット(bit 11)で埋める
    // 論理合成後の回路図で、符号ビットが複数の上位ビットへ分岐して接続される構造を視覚化する
    assign o_imm_16bit[11:0] = i_imm_12bit[11:0];

    genvar i;
    generate
        for (i = 12; i < 16; i = i + 1) begin : gen_sign_bits
            assign o_imm_16bit[i] = i_imm_12bit[11];
        end
    endgenerate

endmodule