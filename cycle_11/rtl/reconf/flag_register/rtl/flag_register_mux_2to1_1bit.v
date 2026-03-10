module flag_register_mux_2to1_1bit (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_y
);

    assign o_y = (i_sel == 1'b1) ? i_d1 : i_d0;

endmodule