module immediate_generator_sign_ext_8to16 (
    input  wire [7:0]  i_imm_8,
    output wire [15:0] o_imm_16
);

    genvar i;

    generate
        // 下位8ビットは入力をそのまま接続
        for (i = 0; i < 8; i = i + 1) begin : gen_low_bits
            assign o_imm_16[i] = i_imm_8[i];
        end

        // 上位8ビットは符号ビット（i_imm_8[7]）で拡張
        for (i = 8; i < 16; i = i + 1) begin : gen_ext_bits
            assign o_imm_16[i] = i_imm_8[7];
        end
    endgenerate

endmodule