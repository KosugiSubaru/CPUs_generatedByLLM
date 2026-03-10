module imm_gen_formatter_12bit (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 符号拡張用のワイヤ（4ビット分）
    wire [3:0] w_sign_ext;

    // 分岐命令（blt, bz）の即値は [15:4] ビットに配置されている
    // その最上位ビット [15] を符号ビットとして抽出し、4ビット分複製する
    imm_gen_bit_repeater #(
        .REPEATS(4)
    ) u_repeater (
        .i_bit (i_instr[15]),
        .o_bus (w_sign_ext)
    );

    // 上位4ビットを符号拡張、下位12ビットに命令内の即値を配置
    assign o_imm = {w_sign_ext, i_instr[15:4]};

endmodule