module flag_reg (
    input  wire i_clk,        // クロック信号
    input  wire i_rst_n,      // 非同期リセット（アクティブ・ロー）
    input  wire i_alu_flag_z, // ALUからのゼロフラグ入力
    input  wire i_alu_flag_n, // ALUからのネガティブフラグ入力
    input  wire i_alu_flag_v, // ALUからのオーバーフローフラグ入力
    output wire o_flag_z,     // 保持されたゼロフラグ出力
    output wire o_flag_n,     // 保持されたネガティブフラグ出力
    output wire o_flag_v      // 保持されたオーバーフローフラグ出力
);

    // generate文での一括処理用のワイヤ
    wire [2:0] w_in_flags;
    wire [2:0] w_out_flags;

    // 入力信号をベクトルにまとめる
    assign w_in_flags[0] = i_alu_flag_z;
    assign w_in_flags[1] = i_alu_flag_n;
    assign w_in_flags[2] = i_alu_flag_v;

    // ループ変数の宣言
    genvar i;

    // 3つのフラグ(Z, N, V)に対してDフリップフロップをインスタンス化
    generate
        for (i = 0; i < 3; i = i + 1) begin : g_flag_storage
            flag_reg_dff u_flag_reg_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (w_in_flags[i]),
                .o_q     (w_out_flags[i])
            );
        end
    endgenerate

    // 保持されたフラグを各ポートへ出力
    assign o_flag_z = w_out_flags[0];
    assign o_flag_n = w_out_flags[1];
    assign o_flag_v = w_out_flags[2];

endmodule