module pc_reg_4bit (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire [3:0] i_d,
    output wire [3:0] o_q
);

    genvar i;

    generate
        for (i = 0; i < 4; i = i + 1) begin : bit_slice
            pc_reg_dff u_pc_reg_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule