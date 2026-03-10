module flag_reg_3bit (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire [2:0] i_d,
    output wire [2:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            // 1ビットDFFを3つ並列に生成し、Z, N, Vの各フラグを個別に保持
            flag_reg_dff u_flag_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule