module pc_reg_nbit_dff (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_d,
    output wire [15:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_dff_array
            pc_reg_1bit_dff u_pc_reg_1bit_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule