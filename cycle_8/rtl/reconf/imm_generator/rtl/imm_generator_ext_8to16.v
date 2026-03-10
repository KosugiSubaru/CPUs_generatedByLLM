module imm_generator_ext_8to16 (
    input  wire [7:0]  i_imm,
    output wire [15:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_ext_8to16
            // generate文内のif-elseを用いることで、コンパイル時のインデックス範囲外アクセスを回避
            if (i < 8) begin : low_bits
                imm_generator_bit_ext u_imm_generator_bit_ext (
                    .i_bit (i_imm[i]),
                    .o_bit (o_q[i])
                );
            end else begin : high_bits
                imm_generator_bit_ext u_imm_generator_bit_ext (
                    .i_bit (i_imm[7]),
                    .o_bit (o_q[i])
                );
            end
        end
    endgenerate

endmodule