module imm_gen_sext4_s (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    genvar i;

    // S型命令（store）の即値フィールド [15:12] を16ビットに符号拡張する
    // 下位4ビット(0-3)に命令の [15:12] を配置し、それ以上(4-15)を符号ビット(bit 15)で埋める
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sext_s
            if (i < 4) begin : bit_data
                imm_gen_bit_ext u_bit (
                    .i_inst_bit    (i_instr[i+12]),
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