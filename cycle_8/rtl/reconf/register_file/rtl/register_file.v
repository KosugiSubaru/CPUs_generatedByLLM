module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [3:0]  i_rd_addr,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    input  wire [15:0] i_rd_data,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    // 内部接続用ワイヤ
    // w_all_regsは16個の16bitレジスタ値を256bitにパックして伝達
    wire [15:0]  w_reg_wens;
    wire [255:0] w_all_regs;

    // --- 1. 書き込み制御階層 ---
    // rd番号と書き込み有効信号をデコードし、16本の有効信号(EN)を生成
    register_file_4to16_dec u_dec (
        .i_wen   (i_wen),
        .i_addr  (i_rd_addr),
        .o_wens  (w_reg_wens)
    );

    // --- 2. 記憶階層（レジスタバンク） ---
    // 実際に値を保持するレジスタ群のインスタンス
    // R0が0固定、R1-R15が実体を持つ構造を内部で構築
    register_file_bank u_bank (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_wens  (w_reg_wens),
        .i_data  (i_rd_data),
        .o_regs  (w_all_regs)
    );

    // --- 3. 読み出しポート階層（パターン構造化） ---
    // 独立した2つの読み出しポート（RS1用、RS2用）をgenerate文で生成
    // 論理合成後の回路図で、同一形状のセレクタブロックが2つ並んで視覚化される
    genvar p;
    generate
        for (p = 0; p < 2; p = p + 1) begin : gen_read_ports
            // 選択信号と出力先をポート番号(p)に応じて分岐
            wire [3:0]  w_target_addr = (p == 0) ? i_rs1_addr : i_rs2_addr;
            wire [15:0] w_out_data;

            register_file_read_mux u_mux (
                .i_sel  (w_target_addr),
                .i_regs (w_all_regs),
                .o_data (w_out_data)
            );

            // ポート出力の接続
            if (p == 0) assign o_rs1_data = w_out_data;
            else        assign o_rs2_data = w_out_data;
        end
    endgenerate

endmodule