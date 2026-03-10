module control_unit_decoder_2to4 (
    input  wire [1:0] i_bin,
    output wire [3:0] o_onehot
);

    assign o_onehot[0] = (~i_bin[1]) & (~i_bin[0]);
    assign o_onehot[1] = (~i_bin[1]) & ( i_bin[0]);
    assign o_onehot[2] = ( i_bin[1]) & (~i_bin[0]);
    assign o_onehot[3] = ( i_bin[1]) & ( i_bin[0]);

endmodule