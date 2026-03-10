module immediate_generator_sign_ext_12to16 (
    input  wire [11:0] i_imm_12,
    output wire [15:0] o_imm_16
);

    genvar i;

    generate
        // 下位12ビットは入力をそのまま接続
        for (i = 0; i < 12; i = i + 1) begin : gen_low_bits
            assign o_imm_16[i] = i_imm_12[i];
        end

        // 上位4ビットは符号ビット（i_imm_12[11]）で拡張
        for (i = 12; i < 16; i = i + 1) begin : gen_ext_bits
            assign o_imm_16[i] = i_imm_12[11];
        end
    endgenerate

endmodule