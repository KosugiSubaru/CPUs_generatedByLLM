module writeback_mux (
    input  wire [15:0] i_alu_result,
    input  wire [15:0] i_mem_data,
    input  wire [15:0] i_pc_plus_2,
    input  wire [1:0]  i_wb_sel,     // 00:ALU, 01:Mem, 10:PC+2
    output wire [15:0] o_wb_data
);

    // 16ビット幅の4入力セレクタをインスタンス化
    // ALU演算結果、メモリ読出値、戻りアドレスの3つのデータパスが
    // レジスタファイルへの書き戻しバスへ集約される様子を視覚化する
    writeback_mux_16bit_4to1 u_mux_logic (
        .i_sel  (i_wb_sel),
        .i_d0   (i_alu_result),
        .i_d1   (i_mem_data),
        .i_d2   (i_pc_plus_2),
        .i_d3   (16'h0000),      // 予約/未使用
        .o_data (o_wb_data)
    );

endmodule