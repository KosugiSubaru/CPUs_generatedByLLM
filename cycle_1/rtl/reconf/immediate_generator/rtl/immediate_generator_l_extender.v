module immediate_generator_l_extender (
    input  wire [11:0] i_imm_bits,
    output wire [15:0] o_imm_ext
);

    // インデックス範囲外参照警告(SELRANGE)を回避するため、
    // 入力をループ範囲をカバーする16ビット幅に拡張した内部ワイヤを用意する
    wire [15:0] w_padded_bits;
    assign w_padded_bits = {4'b0000, i_imm_bits};

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_l_ext
            // L-type(loadi/jal)即値は命令の[11:4]（w_padded_bitsの[7:0]）に位置する
            // 符号ビットは、入力即値の最上位ビットである w_padded_bits[7]
            immediate_generator_sign_ext_bit u_bit (
                .i_raw_bit  ((i < 8) ? w_padded_bits[i] : 1'b0),
                .i_sign_bit (w_padded_bits[7]),
                .i_use_sign (i >= 8),
                .o_ext_bit  (o_imm_ext[i])
            );
        end
    endgenerate

endmodule