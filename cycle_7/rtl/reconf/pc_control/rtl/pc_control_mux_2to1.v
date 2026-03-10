module pc_control_mux_2to1 (
    input  wire i_sel,
    input  wire i_in0,
    input  wire i_in1,
    output wire o_out
);

    assign o_out = i_sel ? i_in1 : i_in0;

endmodule