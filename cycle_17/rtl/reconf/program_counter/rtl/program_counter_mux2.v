module program_counter_mux2 (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_y
);

    assign o_y = (i_sel) ? i_d1 : i_d0;

endmodule