module next_pc_logic_mux_16bit (
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire        i_sel,
    output wire [15:0] o_q
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_bits
            next_pc_logic_mux_bit u_next_pc_logic_mux_bit (
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .i_sel (i_sel),
                .o_q   (o_q[i])
            );
        end
    endgenerate

endmodule