module register_file_reg_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [15:0] i_d,
    output wire [15:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_reg_bits
            // 1ビットレジスタ（Enable付きD-FF）を16個並列に配置し、
            // 16ビットの記憶保持ブロックを構成する
            register_file_bit u_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (i_wen),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule