module imm_gen_sext8_u (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    genvar i;

    // U型命令（loadi, jal等）の即値フィールド [11:4] を16ビットに符号拡張する
    // 下位8ビット(0-7)に命令の [11:4] を配置し、それ以上(8-15)を符号ビット(bit 11)で埋める
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sext_u
            if (i < 8) begin : bit_data
                imm_gen_bit_ext u_bit (
                    .i_inst_bit    (i_instr[i+4]),
                    .i_sign_bit    (i_instr[11]),
                    .i_is_ext_zone  (1'b0),
                    .o_bit          (o_imm[i])
                );
            end else begin : bit_ext
                imm_gen_bit_ext u_bit (
                    .i_inst_bit    (1'b0),
                    .i_sign_bit    (i_instr[11]),
                    .i_is_ext_zone  (1'b1),
                    .o_bit          (o_imm[i])
                );
            end
        end
    endgenerate

endmodule