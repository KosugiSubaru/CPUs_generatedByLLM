module program_counter_mux_4to1_16bit (
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    input  wire [1:0]  i_sel,
    output wire [15:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_16bit
            program_counter_mux_4to1_1bit u_mux_bit (
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .i_d2  (i_d2[i]),
                .i_d3  (i_d3[i]),
                .i_sel (i_sel),
                .o_q   (o_q[i])
            );
        end
    endgenerate

endmodule