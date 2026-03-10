module register_file_word (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_en,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);

    genvar i;

    // 1ビットの記憶素子を16個並列化して、16ビット幅のレジスタ（1ワード）を構成する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_word_bits
            register_file_bit u_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_en),
                .i_d     (i_data[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule