module immediate_generator_sign_ext_4to16 (
    input  wire [3:0]  i_imm_4,
    output wire [15:0] o_imm_16
);

    genvar i;

    generate
        // 下位4ビットは入力をそのまま接続
        for (i = 0; i < 4; i = i + 1) begin : gen_low_bits
            assign o_imm_16[i] = i_imm_4[i];
        end

        // 上位12ビットは符号ビット（i_imm_4[3]）で拡張
        for (i = 4; i < 16; i = i + 1) begin : gen_ext_bits
            assign o_imm_16[i] = i_imm_4[3];
        end
    endgenerate

endmodule