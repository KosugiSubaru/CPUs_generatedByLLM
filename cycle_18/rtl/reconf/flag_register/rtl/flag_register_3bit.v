module flag_register_3bit (
    input wire       i_clk,
    input wire       i_rst_n,
    input wire       i_we,
    input wire [2:0] i_d,
    output wire [2:0] o_q
);

    genvar i;

    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            flag_register_bit u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_we    (i_we),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule