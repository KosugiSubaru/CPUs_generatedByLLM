module immediate_generator_mux2_1bit (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_q
);

    assign o_q = i_sel ? i_d1 : i_d0;

endmodule