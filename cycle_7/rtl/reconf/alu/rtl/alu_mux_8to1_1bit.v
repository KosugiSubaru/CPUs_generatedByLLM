module alu_mux_8to1_1bit (
    input  wire [2:0] i_sel,
    input  wire       i_in0,
    input  wire       i_in1,
    input  wire       i_in2,
    input  wire       i_in3,
    input  wire       i_in4,
    input  wire       i_in5,
    input  wire       i_in6,
    input  wire       i_in7,
    output wire       o_out
);

    assign o_out = (i_sel == 3'b000) ? i_in0 :
                   (i_sel == 3'b001) ? i_in1 :
                   (i_sel == 3'b010) ? i_in2 :
                   (i_sel == 3'b011) ? i_in3 :
                   (i_sel == 3'b100) ? i_in4 :
                   (i_sel == 3'b101) ? i_in5 :
                   (i_sel == 3'b110) ? i_in6 : i_in7;

endmodule