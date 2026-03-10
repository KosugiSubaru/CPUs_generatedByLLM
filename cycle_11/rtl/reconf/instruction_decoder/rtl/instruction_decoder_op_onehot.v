module instruction_decoder_op_onehot (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_inst_active
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_match_cells
            instruction_decoder_match_cell #(
                .P_TARGET_OPCODE(i[3:0])
            ) u_match (
                .i_opcode (i_opcode),
                .o_match  (o_inst_active[i])
            );
        end
    endgenerate

endmodule