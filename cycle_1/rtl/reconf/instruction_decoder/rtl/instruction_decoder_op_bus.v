module instruction_decoder_op_bus (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_instr_signals
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_op_decode
            // 4ビットのオペコードを16本の命令有効信号にデコード
            // i番目のビットが1なら、オペコードがi番の命令であることを示す
            instruction_decoder_op_match u_match (
                .i_opcode (i_opcode),
                .i_target (i[3:0]),
                .o_match  (o_instr_signals[i])
            );
        end
    endgenerate

endmodule