module instruction_decoder_op_selector (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_inst_active
);

    wire [3:0] w_en;

    instruction_decoder_2to4 u_dec_high (
        .i_in (i_opcode[3:2]),
        .i_en (1'b1),
        .o_out (w_en)
    );

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_op_dec
            instruction_decoder_2to4 u_dec_low (
                .i_in  (i_opcode[1:0]),
                .i_en  (w_en[i]),
                .o_out (o_inst_active[i*4 +: 4])
            );
        end
    endgenerate

endmodule