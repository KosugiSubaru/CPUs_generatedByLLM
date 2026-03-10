module control_unit_decoder_onehot (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_onehot
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_opcode_matchers
            // 各命令のオペコード（0000〜1111）と一致するかを判定する比較器を16個並列化
            control_unit_opcode_matcher #(
                .TARGET_OPCODE(i[3:0])
            ) u_matcher (
                .i_opcode (i_opcode),
                .o_match  (o_onehot[i])
            );
        end
    endgenerate

endmodule