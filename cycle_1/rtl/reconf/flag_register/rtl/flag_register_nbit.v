module flag_register_nbit (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_wen,
    input  wire [2:0] i_flags,
    output wire [2:0] o_flags
);

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            // 1ビットレジスタを並列に配置し、Z, N, Vの各フラグを独立して保持
            // 回路図上でフラグの数だけ記憶素子の箱が並ぶ様子を視覚化する
            flag_register_bit u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (i_wen),
                .i_d     (i_flags[i]),
                .o_q     (o_flags[i])
            );
        end
    endgenerate

endmodule