module writeback_mux (
    input  wire        i_mem_to_reg, // メモリからレジスタへのロード選択信号
    input  wire        i_is_jump,    // ジャンプ（リンク）命令選択信号
    input  wire [15:0] i_alu_res,    // ALU演算結果（16ビット）
    input  wire [15:0] i_mem_res,    // メモリからの読み出しデータ（16ビット）
    input  wire [15:0] i_pc_plus_2,  // リンク用アドレス PC+2（16ビット）
    output wire [15:0] o_write_data  // レジスタファイルへの書き込みデータ（16ビット）
);

    // 1ビットマルチプレクサ用の選択信号を生成
    wire [1:0] w_sel;
    assign w_sel[0] = i_mem_to_reg;
    assign w_sel[1] = i_is_jump;

    // ループ変数の宣言
    genvar i;

    // 1ビットマルチプレクサを16個並列に展開し、16ビット幅の選択回路を構成
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_wb_mux_bits
            writeback_mux_1bit u_writeback_mux_1bit (
                .i_sel  (w_sel),
                .i_alu  (i_alu_res[i]),
                .i_mem  (i_mem_res[i]),
                .i_pc2  (i_pc_plus_2[i]),
                .o_data (o_write_data[i])
            );
        end
    endgenerate

endmodule