module flag_reg_bit_array (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_wen,
    input  wire [2:0] i_flags, // [2]:V, [1]:N, [0]:Z
    output wire [2:0] o_flags
);

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            // 3ビットのフラグ（Z, N, V）を個別の記憶素子として構造化
            flag_reg_dff_en u_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_wen),
                .i_d     (i_flags[i]),
                .o_q     (o_flags[i])
            );
        end
    endgenerate

endmodule