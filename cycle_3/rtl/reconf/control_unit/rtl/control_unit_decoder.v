module control_unit_decoder (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_inst_active
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_instruction_decoders
            // 各命令（0～15）に対応する判定ゲートをインスタンス化
            // パラメータ TARGET_OPCODE により、個別の命令を識別する
            control_unit_instruction_gate #(
                .TARGET_OPCODE(i[3:0])
            ) u_gate (
                .i_opcode (i_opcode),
                .o_active (o_inst_active[i])
            );
        end
    endgenerate

endmodule