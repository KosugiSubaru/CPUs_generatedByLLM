module ctrl_unit_matcher_4 #(
    parameter [3:0] P_PATTERN = 4'b0000
) (
    input  wire [3:0] i_data,
    output wire       o_match
);

    assign o_match = (i_data == P_PATTERN);

endmodule