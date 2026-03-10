module control_unit_decoder_4to16 (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_inst
);

    genvar i;

    // generate文を用いて16個のデコードラインをインスタンス化
    // 各インスタンスに異なる比較パターン（0〜15）を渡す
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decode_lines
            control_unit_decode_line #(
                .P_PATTERN(i[3:0])
            ) u_decode_line (
                .i_opcode (i_opcode),
                .o_match  (o_inst[i])
            );
        end
    endgenerate

endmodule