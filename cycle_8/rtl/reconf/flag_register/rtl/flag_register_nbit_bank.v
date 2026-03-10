module flag_register_nbit_bank (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_wen,
    input  wire [2:0] i_data, // [0]:Z, [1]:N, [2]:V
    output wire [2:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            // 単位記憶素子(1bit DFF)を3つ並列に配置
            // 論理合成後の回路図で、ステータスビットが個別に管理されている様子を視覚化
            flag_register_1bit_dff u_flag_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_wen),
                .i_d     (i_data[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule