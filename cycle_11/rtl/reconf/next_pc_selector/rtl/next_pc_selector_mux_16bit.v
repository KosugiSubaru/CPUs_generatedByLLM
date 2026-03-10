module next_pc_selector_mux_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_y
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_mux_slices
            next_pc_selector_mux_1bit u_mux_bit (
                .i_sel (i_sel),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .i_d2  (i_d2[i]),
                .i_d3  (i_d3[i]),
                .o_y   (o_y[i])
            );
        end
    endgenerate

endmodule