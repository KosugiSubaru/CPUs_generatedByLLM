module pc_reg_dff (
    input  wire i_clk,    // クロック信号
    input  wire i_rst_n,  // 非同期リセット（アクティブ・ロー）
    input  wire i_d,      // 入力データ（1ビット）
    output reg  o_q       // 出力データ（1ビット）
);

    // 非同期リセット付きDフリップフロップの基本動作
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else begin
            o_q <= i_d;
        end
    end

endmodule