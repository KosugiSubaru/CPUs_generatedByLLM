module register_file_decoder_2to4 (
    input  wire [1:0] i_sel,
    input  wire       i_en,
    output wire [3:0] o_out
);

    assign o_out[0] = i_en & (~i_sel[1] & ~i_sel[0]);
    assign o_out[1] = i_en & (~i_sel[1] &  i_sel[0]);
    assign o_out[2] = i_en & ( i_sel[1] & ~i_sel[0]);
    assign o_out[3] = i_en & ( i_sel[1] &  i_sel[0]);

endmodule