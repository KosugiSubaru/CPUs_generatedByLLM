module program_counter_register_nbit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_d,
    output wire [15:0] o_q
);

    genvar i;

    // 1ビットレジスタを16個並列に配置し、16ビットレジスタを構成
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_reg
            program_counter_register_1bit u_reg_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule