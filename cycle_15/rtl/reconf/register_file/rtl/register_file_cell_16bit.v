module register_file_cell_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);

    genvar i;

    // generate文を用いて1ビットのイネーブル付DFFを16個並列に配置する
    // これにより、論理合成後の回路図において16ビットのレジスタ構造が視覚化される
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bit_cells
            register_file_dff_en u_dff_en (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_wen),
                .i_d     (i_data[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule