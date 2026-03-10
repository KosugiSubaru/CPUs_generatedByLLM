module imm_gen_sext12_b (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    genvar i;

    // B型命令（branch等）の即値フィールド [15:4] を16ビットに符号拡張する
    // 下位12ビット(0-11)に命令の [15:4] を配置し、それ以上(12-15)を符号ビット(bit 15)で埋める
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sext_b
            if (i < 12) begin : bit_data
                imm_gen_bit_ext u_bit (
                    .i_inst_bit    (i_instr[i+4]),
                    .i_sign_bit    (i_instr[15]),
                    .i_is_ext_zone  (1'b0),
                    .o_bit          (o_imm[i])
                );
            end else begin : bit_ext
                imm_gen_bit_ext u_bit (
                    .i_inst_bit    (1'b0),
                    .i_sign_bit    (i_instr[15]),
                    .i_is_ext_zone  (1'b1),
                    .o_bit          (o_imm[i])
                );
            end
        end
    endgenerate

endmodule