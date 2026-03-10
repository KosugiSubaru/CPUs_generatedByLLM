module register_file_cell_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_en,    // 書き込み許可信号
    input  wire [15:0] i_d,     // 16ビット入力データ
    output wire [15:0] o_q      // 16ビット出力データ
);

    genvar i;

    // 1ビットのメモリセル（FF）を16個並列に配置し、16ビットレジスタを構成
    // これにより論理合成後の回路図でビットスライス構造が視覚化される
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bits
            register_file_cell_1bit u_cell_1bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_en),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule