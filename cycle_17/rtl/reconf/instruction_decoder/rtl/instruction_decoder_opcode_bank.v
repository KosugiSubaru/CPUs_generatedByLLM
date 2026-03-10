module instruction_decoder_opcode_bank (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_matches
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_opcode_match
            instruction_decoder_match_4bit u_match (
                .i_opcode (i_opcode),
                .i_target (i[3:0]),
                .o_match  (o_matches[i])
            );
        end
    endgenerate

endmodule