module reg_file_cell_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_en,      // 書き込み有効信号 (Enable)
    input  wire [15:0] i_d,       // 書き込みデータ (Write Data)
    output reg  [15:0] o_q        // 保持データ出力 (Read Data)
);

    // 16ビット幅の同期書き込み・非同期リセット付きレジスタ
    // 論理合成において1つの「16bitレジスタ」ブロックとして視覚化される
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 16'h0000;
        end else if (i_en) begin
            o_q <= i_d;
        end
    end

endmodule