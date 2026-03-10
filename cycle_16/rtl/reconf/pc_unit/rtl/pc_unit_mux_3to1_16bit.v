module pc_unit_mux_3to1_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    output wire [15:0] o_data
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : mux_bit
            pc_unit_mux_3to1_1bit u_pc_mux_bit (
                .i_sel (i_sel),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .i_d2  (i_d2[i]),
                .o_q   (o_data[i])
            );
        end
    endgenerate

endmodule