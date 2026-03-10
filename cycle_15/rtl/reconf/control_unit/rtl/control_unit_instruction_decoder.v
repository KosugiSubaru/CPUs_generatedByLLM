module control_unit_instruction_decoder (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_inst_onehot
);

    // 4bit入力を16ビットのOne-hot信号へ変換するデコーダをインスタンス化
    control_unit_decoder_4to16 u_decoder_logic (
        .i_opcode (i_opcode),
        .i_en     (1'b1),     // デコーダを常時有効化
        .o_out    (o_inst_onehot)
    );

endmodule