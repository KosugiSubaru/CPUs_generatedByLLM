module register_file_reg_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);

    genvar i;

    // 16ビットのD-FFを並列にインスタンス化
    // クロック、リセット、および書き込み許可信号(wen)を全ビットで共有する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_reg_bits
            register_file_dff u_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_wen),
                .i_d     (i_data[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule