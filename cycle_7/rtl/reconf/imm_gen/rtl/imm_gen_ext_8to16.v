module imm_gen_ext_8to16 (
    input  wire [7:0]  i_in,
    output wire [15:0] o_out
);

    genvar i;
    genvar j;

    // 下位8ビットをそのままコピー
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_lower
            imm_gen_bit_copy u_copy_low (
                .i_bit (i_in[i]),
                .o_bit (o_out[i])
            );
        end
    endgenerate

    // 上位8ビットを入力のMSB(i_in[7])で埋める（符号拡張）
    generate
        for (j = 8; j < 16; j = j + 1) begin : gen_sign_ext
            imm_gen_bit_copy u_copy_sign (
                .i_bit (i_in[7]),
                .o_bit (o_out[j])
            );
        end
    endgenerate

endmodule