module imm_gen (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_type, // 00: 4low, 01: 4high, 10: 8bit, 11: 12bit
    output wire [15:0] o_imm
);

    // 内部ワイヤ：各フォーマッタからの16ビット出力
    wire [15:0] w_imm_4low;
    wire [15:0] w_imm_4high;
    wire [15:0] w_imm_8bit;
    wire [15:0] w_imm_12bit;

    // フォーマッタのインスタンス化
    // 4bit低位抽出 (addi, load, jalr用)
    imm_gen_formatter_4low u_fmt_4low (
        .i_instr (i_instr),
        .o_imm   (w_imm_4low)
    );

    // 4bit高位抽出 (store用)
    imm_gen_formatter_4high u_fmt_4high (
        .i_instr (i_instr),
        .o_imm   (w_imm_4high)
    );

    // 8bit抽出 (loadi, jal用)
    imm_gen_formatter_8bit u_fmt_8bit (
        .i_instr (i_instr),
        .o_imm   (w_imm_8bit)
    );

    // 12bit抽出 (blt, bz用)
    imm_gen_formatter_12bit u_fmt_12bit (
        .i_instr (i_instr),
        .o_imm   (w_imm_12bit)
    );

    // 制御信号に基づき、最終的な即値を選択
    imm_gen_mux_4to1_16bit u_mux (
        .i_sel (i_imm_type),
        .i_d0  (w_imm_4low),
        .i_d1  (w_imm_4high),
        .i_d2  (w_imm_8bit),
        .i_d3  (w_imm_12bit),
        .o_y   (o_imm)
    );

endmodule