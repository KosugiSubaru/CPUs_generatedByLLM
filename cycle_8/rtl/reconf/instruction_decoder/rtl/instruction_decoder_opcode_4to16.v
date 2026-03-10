module instruction_decoder_opcode_4to16 (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_inst_en
);

    wire [3:0] w_dec_high;
    wire [3:0] w_dec_low;

    // --- 1. デコード階層（Level 2モジュールの活用） ---
    // オペコードの上位2ビットをデコード (2to4)
    instruction_decoder_2to4_dec u_dec_high (
        .i_in  (i_opcode[3:2]),
        .o_out (w_dec_high)
    );

    // オペコードの下位2ビットをデコード (2to4)
    instruction_decoder_2to4_dec u_dec_low (
        .i_in  (i_opcode[1:0]),
        .o_out (w_dec_low)
    );

    // --- 2. 展開階層（パタン構造化） ---
    // 上位と下位のデコード結果を組み合わせ、16本のOne-Hot信号を生成
    // 論理合成後の回路図で、4x4の交差点（ANDゲート群）として視覚化される
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_inst_en_signals
            assign o_inst_en[i] = w_dec_high[i / 4] & w_dec_low[i % 4];
        end
    endgenerate

endmodule