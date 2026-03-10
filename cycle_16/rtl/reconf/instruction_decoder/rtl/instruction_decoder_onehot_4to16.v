module instruction_decoder_onehot_4to16 (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_valid
);

    wire [3:0] w_sel_hi;

    // 上位2ビットをデコードして、4つのグループ（バンク）のいずれかを有効にする
    instruction_decoder_onehot_2to4 u_dec_hi (
        .i_en   (1'b1),
        .i_bits (i_opcode[3:2]),
        .o_out  (w_sel_hi)
    );

    // 下位2ビットをデコードして、各グループ内の4信号のうち1つを有効にする
    // パタン構造化のため、上位デコーダーの出力をイネーブル信号として利用
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_dec_lo
            instruction_decoder_onehot_2to4 u_dec_lo (
                .i_en   (w_sel_hi[i]),
                .i_bits (i_opcode[1:0]),
                .o_out  (o_valid[i*4+3 : i*4])
            );
        end
    endgenerate

endmodule