module imm_gen (
    input  wire [15:0] i_instr,   // 命令語全体
    input  wire [1:0]  i_imm_sel, // 即値形式選択信号 (Control Unitより)
    output wire [15:0] o_imm      // 拡張済み即値
);

    wire [15:0] w_imm_0; // 4bit-low 拡張値
    wire [15:0] w_imm_1; // 4bit-high 拡張値
    wire [15:0] w_imm_2; // 8bit 拡張値
    wire [15:0] w_imm_3; // 12bit 拡張値
    wire [15:0] w_mux_mid0; // ステージ1中間出力0
    wire [15:0] w_mux_mid1; // ステージ1中間出力1

    // 各命令フォーマットに対応した抽出・符号拡張ユニットのインスタンス化
    imm_gen_extractor_4bit_low u_ext4l (
        .i_instr_part (i_instr[7:4]),
        .o_imm        (w_imm_0)
    );

    imm_gen_extractor_4bit_high u_ext4h (
        .i_instr_part (i_instr[15:12]),
        .o_imm        (w_imm_1)
    );

    imm_gen_extractor_8bit u_ext8 (
        .i_instr_part (i_instr[11:4]),
        .o_imm        (w_imm_2)
    );

    imm_gen_extractor_12bit u_ext12 (
        .i_instr_part (i_instr[15:4]),
        .o_imm        (w_imm_3)
    );

    // ステージ1: 下位ビット(i_imm_sel[0])で4入力を2つの中間信号に絞り込む
    // エラー回避のため、出力ポート(o_data)には式を記述せず直接信号名を接続する
    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_mux_stage1
            if (i == 0) begin : mux_low
                imm_gen_mux_2to1_16bit u_mux_s1 (
                    .i_sel  (i_imm_sel[0]),
                    .i_d0   (w_imm_0),
                    .i_d1   (w_imm_1),
                    .o_data (w_mux_mid0)
                );
            end else begin : mux_high
                imm_gen_mux_2to1_16bit u_mux_s1 (
                    .i_sel  (i_imm_sel[0]),
                    .i_d0   (w_imm_2),
                    .i_d1   (w_imm_3),
                    .o_data (w_mux_mid1)
                );
            end
        end
    endgenerate

    // ステージ2: 上位ビット(i_imm_sel[1])で最終出力を決定
    imm_gen_mux_2to1_16bit u_mux_stage2 (
        .i_sel  (i_imm_sel[1]),
        .i_d0   (w_mux_mid0),
        .i_d1   (w_mux_mid1),
        .o_data (o_imm)
    );

endmodule