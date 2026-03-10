module instruction_decoder_2to4 (
    input  wire [1:0] i_in,
    input  wire       i_en,
    output wire [3:0] o_out
);

    assign o_out[0] = i_en & (~i_in[1] & ~i_in[0]);
    assign o_out[1] = i_en & (~i_in[1] &  i_in[0]);
    assign o_out[2] = i_en & ( i_in[1] & ~i_in[0]);
    assign o_out[3] = i_en & ( i_in[1] &  i_in[0]);

endmodule