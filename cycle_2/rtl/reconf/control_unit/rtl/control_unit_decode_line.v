module control_unit_decode_line #(
    parameter [3:0] P_PATTERN = 4'b0000
)(
    input  wire [3:0] i_opcode,
    output wire       o_match
);

    // 入力されたopcodeが、パラメータで指定されたパターンと一致するかを判定
    assign o_match = (i_opcode == P_PATTERN);

endmodule