module writeback_mux (
    input  wire [15:0] i_alu_result,
    input  wire [15:0] i_mem_data,
    input  wire [15:0] i_pc_plus_2,
    input  wire [1:0]  i_wb_sel,    // 00: ALU, 01: Mem, 10: PC+2
    output wire [15:0] o_wb_data
);

    wire [15:0] w_alu_or_mem;

    // 16ビット幅の2入力セレクタを階層的に組み合わせることで、木構造の選択路を構築する
    // 論理合成後の回路図で、データが段階的に絞り込まれる様子を視覚化する

    // 第1段: ALUの計算結果か、メモリからの読み出し値かを選択
    // i_wb_sel[0] が 1 のとき i_mem_data を選択
    writeback_mux_2to1_16bit u_mux_stage1 (
        .i_sel  (i_wb_sel[0]),
        .i_d0   (i_alu_result),
        .i_d1   (i_mem_data),
        .o_data (w_alu_or_mem)
    );

    // 第2段: 前段の結果か、リンクアドレス（PC+2）かを選択
    // i_wb_sel[1] が 1 のとき i_pc_plus_2 を選択
    writeback_mux_2to1_16bit u_mux_stage2 (
        .i_sel  (i_wb_sel[1]),
        .i_d0   (w_alu_or_mem),
        .i_d1   (i_pc_plus_2),
        .o_data (o_wb_data)
    );

endmodule