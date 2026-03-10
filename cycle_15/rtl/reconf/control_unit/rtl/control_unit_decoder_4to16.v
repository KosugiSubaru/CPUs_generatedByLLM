module control_unit_decoder_4to16 (
    input  wire [3:0]  i_opcode,
    input  wire        i_en,
    output wire [15:0] o_out
);

    wire [3:0] w_enable_lines;
    genvar i;

    // 上位2ビット(opcode[3:2])をデコードし、4つの下位デコーダのうちどれを活性化するか決定する
    control_unit_decoder_2to4 u_dec_upper (
        .i_sel (i_opcode[3:2]),
        .i_en  (i_en),
        .o_out (w_enable_lines)
    );

    // 下位2ビット(opcode[1:0])をデコードする2to4デコーダを4つ並列に配置し、
    // 全体として4to16デコーダを構成する（パタン構造化）
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_decoders
            control_unit_decoder_2to4 u_dec_lower (
                .i_sel (i_opcode[1:0]),
                .i_en  (w_enable_lines[i]),
                .o_out (o_out[i*4 +: 4])
            );
        end
    endgenerate

endmodule