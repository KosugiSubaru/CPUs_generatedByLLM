module immediate_generator_i_extender (
    input  wire [11:0] i_imm_bits,
    output wire [15:0] o_imm_ext
);

    // インデックス範囲外参照エラー(SELRANGE)を避けるため、
    // 入力信号を16ビットにパディングした作業用ワイヤを用意する
    wire [15:0] w_padded_bits;
    assign w_padded_bits = {4'b0000, i_imm_bits};

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_i_ext
            // I-type即値は命令の[7:4]（w_padded_bitsの[3:0]）に位置する
            // 符号ビットは即値フィールドの最上位である w_padded_bits[3]
            immediate_generator_sign_ext_bit u_bit (
                .i_raw_bit  ((i < 4) ? w_padded_bits[i] : 1'b0),
                .i_sign_bit (w_padded_bits[3]),
                .i_use_sign (i >= 4),
                .o_ext_bit  (o_imm_ext[i])
            );
        end
    endgenerate

endmodule