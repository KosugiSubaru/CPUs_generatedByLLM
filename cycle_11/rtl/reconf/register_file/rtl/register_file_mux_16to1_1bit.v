module register_file_mux_16to1_1bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_d,
    output wire        o_y
);

    assign o_y = i_d[i_sel];

endmodule