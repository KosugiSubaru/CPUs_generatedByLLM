module flag_reg_dff (
    input  wire i_clk,   // クロック信号
    input  wire i_rst_n, // 非同期リセット（アクティブ・ロー）
    input  wire i_d,     // 入力フラグ（1ビット）
    output reg  o_q      // 保持されたフラグ出力（1ビット）
);

    // 非同期リセット付きDフリップフロップ
    // 前の命令のフラグ状態を1クロック分保持する
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else begin
            o_q <= i_d;
        end
    end

endmodule