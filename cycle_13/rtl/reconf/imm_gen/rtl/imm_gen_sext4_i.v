module imm_gen_sext4_i (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    genvar i;

    // I型命令の即値フィールド [7:4] を16ビットに符号拡張する
    // 下位4ビット(0-3)に命令ビットを配置し、それ以上(4-15)を符号ビット(bit 7)で埋める
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sext_i
            if (i < 4) begin : bit_data
                imm_gen_bit_ext u_bit (
                    .i_inst_bit    (i_instr[i+4]),
                    .i_sign_bit    (i_instr[7]),
                    .i_is_ext_zone  (1'b0),
                    .o_bit          (o_imm[i])
                );
            end else begin : bit_ext
                imm_gen_bit_ext u_bit (
                    .i_inst_bit    (1'b0),
                    .i_sign_bit    (i_instr[7]),
                    .i_is_ext_zone  (1'b1),
                    .o_bit          (o_imm[i])
                );
            end
        end
    endgenerate

endmodule