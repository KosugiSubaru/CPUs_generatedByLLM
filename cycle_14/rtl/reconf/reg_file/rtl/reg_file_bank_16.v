module reg_file_bank_16 (
        input  wire         i_clk,
        input  wire         i_rst_n,
        input  wire [15:0]  i_wen_vec,   // デコーダで生成された16本のEnable信号
        input  wire [15:0]  i_wd,        // 書込データ（全レジスタ共通）
        output wire [255:0] o_rd_all     // 全レジスタの値を束ねた出力バス
    );

        // ISA定義: ゼロレジスタ (reg 0)
        // 常に0を返し、書き込み不可。回路図上で配線として明示。
        assign o_rd_all[15:0] = 16'h0000;

        // レジスタ 1-15 の生成
        // パタン構造化のため、共通のセルモジュールを繰り返し配置。
        genvar i;
        generate
            for (i = 1; i < 16; i = i + 1) begin : gen_reg_cells
                reg_file_cell_16bit u_reg_cell (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_en    (i_wen_vec[i]),
                    .i_d     (i_wd),
                    .o_q     (o_rd_all[i*16 +: 16])
                );
            end
        endgenerate

    endmodule