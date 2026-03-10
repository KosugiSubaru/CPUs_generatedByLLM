module imm_gen_mux_4to1_1bit (
    input  wire [1:0] i_sel,
    input  wire       i_in0,
    input  wire       i_in1,
    input  wire       i_in2,
    input  wire       i_in3,
    output wire       o_out
);

    assign o_out = (i_sel == 2'b00) ? i_in0 :
                   (i_sel == 2'b01) ? i_in1 :
                   (i_sel == 2'b10) ? i_in2 : i_in3;

endmodule