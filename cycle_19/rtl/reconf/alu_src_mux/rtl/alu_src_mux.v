module alu_src_mux (
    input  wire        i_sel,  // 選択信号 (0: rs2_data, 1: imm_data)
    input  wire [15:0] i_rs2,  // レジスタファイルからの出力 (16ビット)
    input  wire [15:0] i_imm,  // 即値ジェネレータからの出力 (16ビット)
    output wire [15:0] o_data  // ALUの入力Bへ送るデータ (16ビット)
);

    // generate文用のループ変数の宣言
    genvar i;

    // 1ビットマルチプレクサを16個並列に配置し、16ビット幅の選択回路を構成
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_mux_bits
            alu_src_mux_1bit u_alu_src_mux_1bit (
                .i_sel  (i_sel),
                .i_rs2  (i_rs2[i]),
                .i_imm  (i_imm[i]),
                .o_data (o_data[i])
            );
        end
    endgenerate

endmodule