module pc_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_next_pc,
    output wire [15:0] o_now_pc
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_pc_bits
            pc_reg_dff u_pc_reg_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_next_pc[i]),
                .o_q     (o_now_pc[i])
            );
        end
    endgenerate

endmodule