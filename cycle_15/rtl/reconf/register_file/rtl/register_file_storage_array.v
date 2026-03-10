module register_file_storage_array (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire [15:0]  i_wen_bus,   // 16本それぞれの書き込み有効信号
    input  wire [15:0]  i_data,      // 共通の書き込みデータ
    output wire [255:0] o_regs_flat  // 全16レジスタを束ねたバス (16bit * 16)
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_regs
            if (i == 0) begin : r0_special
                // 常に0を返す特殊レジスタ (R0)
                register_file_zero_cell_16bit u_zero_cell (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_wen   (i_wen_bus[i]),
                    .i_data  (i_data),
                    .o_data  (o_regs_flat[15:0])
                );
            end else begin : r_normal
                // 通常の16ビットレジスタ (R1-R15)
                register_file_cell_16bit u_reg_cell (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_wen   (i_wen_bus[i]),
                    .i_data  (i_data),
                    .o_data  (o_regs_flat[i*16 +: 16])
                );
            end
        end
    endgenerate

endmodule