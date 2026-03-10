module alu_mux_8to1_16bit (
    input  wire [2:0]  i_sel,
    input  wire [15:0] i_in0,
    input  wire [15:0] i_in1,
    input  wire [15:0] i_in2,
    input  wire [15:0] i_in3,
    input  wire [15:0] i_in4,
    input  wire [15:0] i_in5,
    input  wire [15:0] i_in6,
    input  wire [15:0] i_in7,
    output wire [15:0] o_out
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_16bit
            alu_mux_8to1_1bit u_mux_bit (
                .i_sel (i_sel),
                .i_in0 (i_in0[i]),
                .i_in1 (i_in1[i]),
                .i_in2 (i_in2[i]),
                .i_in3 (i_in3[i]),
                .i_in4 (i_in4[i]),
                .i_in5 (i_in5[i]),
                .i_in6 (i_in6[i]),
                .i_in7 (i_in7[i]),
                .o_out (o_out[i])
            );
        end
    endgenerate

endmodule