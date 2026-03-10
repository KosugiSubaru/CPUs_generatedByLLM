module register_file_cell_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_en,
    input  wire [15:0] i_d,
    output wire [15:0] o_q
);

    genvar i;

    // 16ビットのレジスタセルを1ビット単位のセルを16個並列化して構成
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bit_cells
            register_file_cell_1bit u_bit_cell (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_en),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule