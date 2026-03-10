module instruction_decoder_op_match (
    input  wire [3:0] i_opcode,
    input  wire [3:0] i_target,
    output wire       o_match
);

    // 入力されたオペコードが、指定されたターゲット値と一致するかを比較
    assign o_match = (i_opcode == i_target);

endmodule