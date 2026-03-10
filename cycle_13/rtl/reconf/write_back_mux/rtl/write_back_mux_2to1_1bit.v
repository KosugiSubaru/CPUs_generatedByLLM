module write_back_mux_2to1_1bit (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_data
);

    assign o_data = i_sel ? i_d1 : i_d0;

endmodule