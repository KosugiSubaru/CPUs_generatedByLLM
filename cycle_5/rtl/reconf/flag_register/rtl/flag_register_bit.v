module flag_register_bit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_en,    // 更新有効信号
    input  wire i_d,     // 入力フラグ値
    output reg  o_q      // 保持されているフラグ値
);

    // 非同期リセット付き、更新有効信号(i_en)を持つD-フリップフロップ
    // i_enが1の時（演算命令実行時）のみ、ALUの結果を記憶する
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else if (i_en) begin
            o_q <= i_d;
        end
    end

endmodule