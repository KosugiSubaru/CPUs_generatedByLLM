module control_unit_instruction_gate #(
    parameter [3:0] TARGET_OPCODE = 4'b0000
)(
    input  wire [3:0] i_opcode,
    output wire       o_active
);

    // 入力されたopcodeが、パラメータで指定されたターゲットと一致するか判定
    assign o_active = (i_opcode == TARGET_OPCODE);

endmodule