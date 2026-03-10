module program_counter_mux2_16bit (
    input  wire        i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    output wire [15:0] o_y
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux
            program_counter_mux2 u_mux (
                .i_sel (i_sel),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .o_y   (o_y[i])
            );
        end
    endgenerate

endmodule