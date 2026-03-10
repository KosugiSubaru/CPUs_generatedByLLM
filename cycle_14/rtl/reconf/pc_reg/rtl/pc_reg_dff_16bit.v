module pc_reg_dff_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_d,
    output wire [15:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : bit_slice_dff
            pc_reg_dff_1bit u_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule