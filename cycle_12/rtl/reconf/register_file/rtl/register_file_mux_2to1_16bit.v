module register_file_mux_2to1_16bit (
    input  wire        i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_bits
            assign o_data[i] = (i_sel == 1'b0) ? i_d0[i] : i_d1[i];
        end
    endgenerate

endmodule