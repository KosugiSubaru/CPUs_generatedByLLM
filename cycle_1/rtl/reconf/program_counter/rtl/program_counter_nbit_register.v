module program_counter_nbit_register (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_d,
    output wire [15:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_reg
            program_counter_bit_register u_bit_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule