module imm_gen_ext_4to16 (
    input  wire [3:0]  i_imm,
    output wire [15:0] o_imm
);

    genvar i;

    // 4ビット入力を16ビットに拡張
    // 下位4ビットは入力をそのまま接続し、上位12ビットには符号ビット(bit 3)をコピーする
    // generate文を用いることで、回路図上で符号ビットが分配される様子を視覚化する
    generate
        // 下位ビットの直接接続
        for (i = 0; i < 4; i = i + 1) begin : gen_lower
            assign o_imm[i] = i_imm[i];
        end
        // 上位ビットへの符号拡張
        for (i = 4; i < 16; i = i + 1) begin : gen_sign_ext
            assign o_imm[i] = i_imm[3];
        end
    endgenerate

endmodule