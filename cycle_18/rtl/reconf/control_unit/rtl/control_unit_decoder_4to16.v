module control_unit_decoder_4to16 (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_instr_active
);

    wire [3:0] w_high;
    wire [3:0] w_low;
    genvar i;

    control_unit_decoder_2to4 u_dec_high (
        .i_bin    (i_opcode[3:2]),
        .o_onehot (w_high)
    );

    control_unit_decoder_2to4 u_dec_low (
        .i_bin    (i_opcode[1:0]),
        .o_onehot (w_low)
    );

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decode_matrix
            assign o_instr_active[i] = w_high[i / 4] & w_low[i % 4];
        end
    endgenerate

endmodule