module ctrl_unit_decoder_16 (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_active
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : decode_loop
            // 各ビットに対応する命令コード（0-15）とopcodeを比較
            ctrl_unit_matcher_4 #(
                .P_PATTERN(i[3:0])
            ) u_matcher (
                .i_data  (i_opcode),
                .o_match (o_active[i])
            );
        end
    endgenerate

endmodule