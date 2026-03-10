module register_file_reg_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_en,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_reg_bits
            // 1ビットの記憶素子(D-FF)を16個並列に配置して16ビットレジスタを構成
            register_file_dff_en u_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_en),
                .i_d     (i_data[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule