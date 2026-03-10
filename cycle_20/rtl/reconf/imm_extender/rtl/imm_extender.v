module imm_extender (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_sel,
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_4b_mid;
    wire [15:0] w_imm_4b_top;
    wire [15:0] w_imm_8b;
    wire [15:0] w_imm_12b;

    // 命令ビット[7:4]の抽出と符号拡張 (addi, load, jalr用)
    imm_extender_fmt_4b_mid u_imm_extender_fmt_4b_mid (
        .i_instr (i_instr),
        .o_imm   (w_imm_4b_mid)
    );

    // 命令ビット[15:12]の抽出と符号拡張 (store用)
    imm_extender_fmt_4b_top u_imm_extender_fmt_4b_top (
        .i_instr (i_instr),
        .o_imm   (w_imm_4b_top)
    );

    // 命令ビット[11:4]の抽出と符号拡張 (loadi, jal用)
    imm_extender_fmt_8b u_imm_extender_fmt_8b (
        .i_instr (i_instr),
        .o_imm   (w_imm_8b)
    );

    // 命令ビット[15:4]の抽出と符号拡張 (blt, bz用)
    imm_extender_fmt_12b u_imm_extender_fmt_12b (
        .i_instr (i_instr),
        .o_imm   (w_imm_12b)
    );

    // フォーマット選択用マルチプレクサ
    imm_extender_mux_4to1_16b u_imm_extender_mux_4to1_16b (
        .i_sel   (i_imm_sel),
        .i_data0 (w_imm_4b_mid),
        .i_data1 (w_imm_4b_top),
        .i_data2 (w_imm_8b),
        .i_data3 (w_imm_12b),
        .o_data  (o_imm)
    );

endmodule