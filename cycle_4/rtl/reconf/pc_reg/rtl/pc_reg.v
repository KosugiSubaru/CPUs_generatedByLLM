module pc_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_pc_next,
    output wire [15:0] o_pc_current
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_bits
            pc_reg_1bit u_pc_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_pc_next[i]),
                .o_q     (o_pc_current[i])
            );
        end
    endgenerate

endmodule