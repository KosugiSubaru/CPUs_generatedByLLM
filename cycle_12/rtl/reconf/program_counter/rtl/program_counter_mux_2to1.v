module program_counter_mux_2to1 (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_data
);

    assign o_data = (i_sel == 1'b0) ? i_d0 : i_d1;

endmodule