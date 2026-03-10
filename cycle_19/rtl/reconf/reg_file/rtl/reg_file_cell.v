module reg_file_cell (
    input  wire        i_clk,   // クロック信号
    input  wire        i_rst_n, // 非同期リセット（アクティブ・ロー）
    input  wire        i_wen,   // 書き込み有効信号
    input  wire [15:0] i_data,  // 書き込みデータ（16ビット）
    output reg  [15:0] o_data   // 保持データ（16ビット）
);

    // クロック同期でのデータ更新、非同期リセット
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_data <= 16'h0000;
        end else if (i_wen) begin
            o_data <= i_data;
        end
    end

endmodule