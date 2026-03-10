module pc_reg (
    input  wire        i_clk,     // クロック信号
    input  wire        i_rst_n,   // 非同期リセット（アクティブ・ロー）
    input  wire [15:0] i_next_pc, // 次のプログラムカウンタ値
    output wire [15:0] o_pc        // 現在のプログラムカウンタ値
);

    // generate文用のループ変数の宣言
    genvar i;

    // 1ビットのDフリップフロップを16個並列に配置し、16ビットレジスタを構成
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_pc_bits
            pc_reg_dff u_pc_reg_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_next_pc[i]),
                .o_q     (o_pc[i])
            );
        end
    endgenerate

endmodule