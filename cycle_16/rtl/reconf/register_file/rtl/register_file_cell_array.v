module register_file_cell_array (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire         i_wen,         // 全体の書き込み許可
    input  wire [15:0]  i_sel_onehot,  // 書き込み先選択（One-hot）
    input  wire [15:0]  i_data,
    output wire [255:0] o_all_data     // R0〜R15の全データバス
);

    genvar i;

    // R0の特殊処理: 常に0を返す（回路図上でFFが存在しないことを示す）
    assign o_all_data[15:0] = 16'h0000;

    // R1からR15までのレジスタを生成
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_regs
            register_file_cell_16bit u_reg_cell (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_wen & i_sel_onehot[i]),
                .i_d     (i_data),
                .o_q     (o_all_data[i*16 +: 16])
            );
        end
    endgenerate

endmodule