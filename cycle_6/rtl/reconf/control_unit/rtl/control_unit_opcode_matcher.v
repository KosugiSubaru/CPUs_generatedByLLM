module control_unit_opcode_matcher #(
    parameter [3:0] TARGET_OPCODE = 4'b0000
)(
    input  wire [3:0] i_opcode,
    output wire       o_match
);

    // 入力されたオペコードが、パラメータで指定されたターゲット値と一致するか判定
    assign o_match = (i_opcode == TARGET_OPCODE);

endmodule