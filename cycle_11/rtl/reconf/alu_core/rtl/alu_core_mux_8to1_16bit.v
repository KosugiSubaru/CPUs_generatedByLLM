module alu_core_mux_8to1_16bit (
    input  wire [2:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    input  wire [15:0] i_d4,
    input  wire [15:0] i_d5,
    input  wire [15:0] i_d6,
    input  wire [15:0] i_d7,
    output wire [15:0] o_y
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_slices
            alu_core_mux_8to1_1bit u_mux_bit (
                .i_sel (i_sel),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .i_d2  (i_d2[i]),
                .i_d3  (i_d3[i]),
                .i_d4  (i_d4[i]),
                .i_d5  (i_d5[i]),
                .i_d6  (i_d6[i]),
                .i_d7  (i_d7[i]),
                .o_y   (o_y[i])
            );
        end
    endgenerate

endmodule