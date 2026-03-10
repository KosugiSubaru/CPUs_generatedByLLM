module immediate_generator_s_extender (
    input  wire [11:0] i_imm_bits,
    output wire [15:0] o_imm_ext
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_s_ext
            // S-type(Store)即値は命令の[15:12]（i_imm_bitsの[11:8]）に位置する
            // 符号ビットはi_imm_bits[11]
            immediate_generator_sign_ext_bit u_bit (
                .i_raw_bit  ((i < 4) ? i_imm_bits[i+8] : 1'b0),
                .i_sign_bit (i_imm_bits[11]),
                .i_use_sign (i >= 4),
                .o_ext_bit  (o_imm_ext[i])
            );
        end
    endgenerate

endmodule