module imm_gen_ext_12to16 (
    input  wire [11:0] i_in,
    output wire [15:0] o_out
);

    genvar i;
    genvar j;

    // 下位12ビットをそのままコピー
    generate
        for (i = 0; i < 12; i = i + 1) begin : gen_lower
            imm_gen_bit_copy u_copy_low (
                .i_bit (i_in[i]),
                .o_bit (o_out[i])
            );
        end
    endgenerate

    // 上位4ビットを入力のMSB(i_in[11])で埋める（符号拡張）
    generate
        for (j = 12; j < 16; j = j + 1) begin : gen_sign_ext
            imm_gen_bit_copy u_copy_sign (
                .i_bit (i_in[11]),
                .o_bit (o_out[j])
            );
        end
    endgenerate

endmodule