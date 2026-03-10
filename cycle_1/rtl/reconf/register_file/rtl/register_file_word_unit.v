module register_file_word_unit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_word_bits
            // 1ビット記憶素子を16個並列化して1ワードレジスタを構成
            register_file_bit_cell u_bit_cell (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (i_wen),
                .i_d     (i_data[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule