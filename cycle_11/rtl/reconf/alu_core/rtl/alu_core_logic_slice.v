module alu_core_logic_slice (
    input  wire       i_a,
    input  wire       i_b,
    input  wire [1:0] i_sel,
    output wire       o_res
);

    assign o_res = (i_sel == 2'b10) ? (i_a & i_b) :
                   (i_sel == 2'b11) ? (i_a | i_b) :
                   (i_sel == 2'b00) ? (i_a ^ i_b) :
                                      (~i_a);

endmodule