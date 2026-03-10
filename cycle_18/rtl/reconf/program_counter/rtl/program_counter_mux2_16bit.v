module program_counter_mux2_16bit (
    input wire        i_sel,
    input wire [15:0] i_d0,
    input wire [15:0] i_d1,
    output wire [15:0] o_q
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_mux
            program_counter_mux2_1bit u_mux_1bit (
                .i_sel (i_sel),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .o_q   (o_q[i])
            );
        end
    endgenerate

endmodule