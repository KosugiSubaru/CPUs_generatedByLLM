module program_counter_mux_4to1_1bit (
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    input  wire [1:0] i_sel,
    output wire       o_q
);

    assign o_q = (i_sel == 2'b00) ? i_d0 :
                 (i_sel == 2'b01) ? i_d1 :
                 (i_sel == 2'b10) ? i_d2 : i_d3;

endmodule