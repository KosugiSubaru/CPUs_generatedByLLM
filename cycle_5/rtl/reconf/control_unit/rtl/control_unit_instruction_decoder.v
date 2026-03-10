module control_unit_instruction_decoder (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_inst_onehot
);

    wire [3:0] w_upper_enable;
    genvar i;

    // 上位2ビットをデコードして、下位デコーダ群の有効化信号を生成
    control_unit_decoder_2to4 u_dec_hi (
        .i_in  (i_opcode[3:2]),
        .i_en  (1'b1),
        .o_out (w_upper_enable)
    );

    // 下位2ビットをデコードして、最終的な16本の命令信号を生成
    // generate文を用いて4つの2to4デコーダを配置するパターン構造
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_dec_lo
            control_unit_decoder_2to4 u_dec_lo (
                .i_in  (i_opcode[1:0]),
                .i_en  (w_upper_enable[i]),
                .o_out (o_inst_onehot[i*4 +: 4])
            );
        end
    endgenerate

endmodule