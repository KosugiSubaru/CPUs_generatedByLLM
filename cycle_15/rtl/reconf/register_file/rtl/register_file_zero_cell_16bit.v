module register_file_zero_cell_16bit (
    input  wire        i_clk,   // 配線整合用（不使用）
    input  wire        i_rst_n, // 配線整合用（不使用）
    input  wire        i_wen,   // 配線整合用（不使用）
    input  wire [15:0] i_data,  // 配線整合用（不使用）
    output wire [15:0] o_data
);

    // ゼロレジスタ(R0)の物理的実装
    // 書き込み回路を持たず、常に16ビットの0を出力する固定配線
    assign o_data = 16'h0000;

endmodule