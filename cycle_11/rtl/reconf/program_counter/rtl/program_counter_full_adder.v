module program_counter_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    wire w_sum_ha1;
    wire w_cout_ha1;
    wire w_cout_ha2;

    program_counter_half_adder u_ha1 (
        .i_a    (i_a),
        .i_b    (i_b),
        .o_sum  (w_sum_ha1),
        .o_cout (w_cout_ha1)
    );

    program_counter_half_adder u_ha2 (
        .i_a    (w_sum_ha1),
        .i_b    (i_cin),
        .o_sum  (o_sum),
        .o_cout (w_cout_ha2)
    );

    assign o_cout = w_cout_ha1 | w_cout_ha2;

endmodule