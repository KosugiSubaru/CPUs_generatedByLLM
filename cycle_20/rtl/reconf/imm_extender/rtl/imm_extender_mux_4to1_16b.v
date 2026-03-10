module imm_extender_mux_4to1_16b (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_data0,
    input  wire [15:0] i_data1,
    input  wire [15:0] i_data2,
    input  wire [15:0] i_data3,
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_mux_bits
            imm_extender_mux_4to1_1b u_imm_extender_mux_4to1_1b (
                .i_sel (i_sel),
                .i_in0 (i_data0[i]),
                .i_in1 (i_data1[i]),
                .i_in2 (i_data2[i]),
                .i_in3 (i_data3[i]),
                .o_out (o_data[i])
            );
        end
    endgenerate

endmodule