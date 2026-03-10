module register_file_storage (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire [15:0]  i_enables,      // デコーダからの各レジスタ書き込み許可
    input  wire [15:0]  i_data,         // 書き込みデータ
    output wire [255:0] o_all_data      // 全16レジスタの出力（16ビット×16本）
);

    genvar i;

    // ISA定義の「R0は常に0、書き込み不可」を回路構造で実現
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_regs
            if (i == 0) begin : r0_logic
                // R0: ゼロレジスタ
                // インスタンス化せず、出力を直接0に固定することで視覚化
                assign o_all_data[15:0] = 16'h0000;
            end else begin : rn_logic
                // R1 - R15: 通常の16ビットレジスタセル
                register_file_cell_16bit u_reg_16bit (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_en    (i_enables[i]),
                    .i_d     (i_data),
                    .o_q     (o_all_data[i*16 +: 16])
                );
            end
        end
    endgenerate

endmodule