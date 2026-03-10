module instruction_decoder_match (
    input  wire [3:0] i_opcode,        // 命令コード（4ビット）
    input  wire [3:0] i_target_opcode, // 比較対象のオペコード
    output wire       o_match          // 一致信号
);

    // 入力されたオペコードがターゲットと一致するか判定
    assign o_match = (i_opcode == i_target_opcode);

endmodule