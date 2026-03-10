module imm_gen_formatter_8bit (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 符号拡張用のワイヤ（8ビット分）
    wire [7:0] w_sign_ext;

    // loadi, jal命令の即値は [11:4] ビットに配置されている
    // その最上位ビット [11] を符号ビットとして抽出し、8ビット分複製する
    imm_gen_bit_repeater #(
        .REPEATS(8)
    ) u_repeater (
        .i_bit (i_instr[11]),
        .o_bus (w_sign_ext)
    );

    // 上位8ビットを符号拡張、下位8ビットに命令内の即値を配置
    assign o_imm = {w_sign_ext, i_instr[11:4]};

endmodule