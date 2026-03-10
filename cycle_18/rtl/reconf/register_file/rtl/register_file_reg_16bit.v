module register_file_reg_16bit (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_we,
    input wire [15:0] i_d,
    output wire [15:0] o_q
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_reg_slice
            register_file_cell_1bit u_cell (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_we    (i_we),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule