module imm_gen_ext_4to16 (
    input  wire [3:0]  i_in,
    output wire [15:0] o_out
);

    genvar i;
    genvar j;

    // 下位4ビットをそのままコピー
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_lower
            imm_gen_bit_copy u_copy_low (
                .i_bit (i_in[i]),
                .o_bit (o_out[i])
            );
        end
    endgenerate

    // 上位12ビットを入力のMSB(i_in[3])で埋める（符号拡張）
    generate
        for (j = 4; j < 16; j = j + 1) begin : gen_sign_ext
            imm_gen_bit_copy u_copy_sign (
                .i_bit (i_in[3]),
                .o_bit (o_out[j])
            );
        end
    endgenerate

endmodule