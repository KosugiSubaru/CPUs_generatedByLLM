module instruction_decoder_match_4bit (
    input  wire [3:0] i_opcode,
    input  wire [3:0] i_target,
    output wire       o_match
);

    assign o_match = (i_opcode == i_target);

endmodule