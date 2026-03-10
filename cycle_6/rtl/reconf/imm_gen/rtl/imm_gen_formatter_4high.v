module imm_gen_formatter_4high (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 符号拡張用のワイヤ（12ビット分）
    wire [11:0] w_sign_ext;

    // store命令の即値は上位4ビット[15:12]に配置されている
    // その最上位ビット[15]を符号ビットとして抽出し、12ビット分複製する
    imm_gen_bit_repeater #(
        .REPEATS(12)
    ) u_repeater (
        .i_bit (i_instr[15]),
        .o_bus (w_sign_ext)
    );

    // 上位12ビットを符号拡張、下位4ビットに命令内の即値を配置
    assign o_imm = {w_sign_ext, i_instr[15:12]};

endmodule