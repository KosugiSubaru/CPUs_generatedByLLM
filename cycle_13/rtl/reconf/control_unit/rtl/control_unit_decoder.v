module control_unit_decoder (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_instr_signals
);

    genvar i;

    // 4ビットのオペコードを16本のワンホット信号に展開する
    // 各ビットがISA定義の各オペコード（0000～1111）に対応する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decoder
            control_unit_op_match u_match (
                .i_opcode (i_opcode),
                .i_target (i[3:0]),
                .o_match  (o_instr_signals[i])
            );
        end
    endgenerate

endmodule