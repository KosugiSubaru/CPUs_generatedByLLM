module register_file_cell_bank (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire [15:0]  i_wen_bus,
    input  wire [15:0]  i_data,
    output wire [255:0] o_data_bus
);

    genvar i;

    // 16個のレジスタスロットを生成
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_reg_bank
            if (i == 0) begin : r0_fixed_zero
                // レジスタ0は常に0を出力（回路図上で固定配線として視覚化）
                assign o_data_bus[15:0] = 16'h0000;
            end else begin : r_general
                // レジスタ1-15の実体をインスタンス化
                register_file_reg_16bit u_reg_16bit (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_wen   (i_wen_bus[i]),
                    .i_data  (i_data),
                    .o_data  (o_data_bus[i*16 +: 16])
                );
            end
        end
    endgenerate

endmodule