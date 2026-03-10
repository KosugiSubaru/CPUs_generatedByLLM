module program_counter_nbit_mux_4to1 (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_16bit
            program_counter_mux_4to1_1bit u_mux (
                .i_sel  (i_sel),
                .i_d0   (i_d0[i]),
                .i_d1   (i_d1[i]),
                .i_d2   (i_d2[i]),
                .i_d3   (i_d3[i]),
                .o_data (o_data[i])
            );
        end
    endgenerate

endmodule