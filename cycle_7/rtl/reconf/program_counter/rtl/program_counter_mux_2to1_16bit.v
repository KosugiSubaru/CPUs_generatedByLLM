module program_counter_mux_2to1_16bit (
    input  wire        i_sel,
    input  wire [15:0] i_in0,
    input  wire [15:0] i_in1,
    output wire [15:0] o_out
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_mux
            program_counter_mux_2to1_1bit u_mux_bit (
                .i_sel (i_sel),
                .i_in0 (i_in0[i]),
                .i_in1 (i_in1[i]),
                .o_out (o_out[i])
            );
        end
    endgenerate

endmodule