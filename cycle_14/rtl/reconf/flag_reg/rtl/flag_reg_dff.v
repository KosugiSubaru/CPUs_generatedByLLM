module flag_reg_dff (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_en,      // 書き込み有効信号
    input  wire i_d,       // 入力データ
    output reg  o_q        // 出力データ（保持値）
);

    // 非同期リセット付き、Enable信号付きの1ビットDフリップフロップ
    // 命令セットの「1クロック前のフラグを参照する」動作を実現するための最小単位
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else if (i_en) begin
            o_q <= i_d;
        end
    end

endmodule