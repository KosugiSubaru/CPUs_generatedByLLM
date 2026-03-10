module writeback_mux (
    input  wire [1:0]  i_sel,        // 00:ALU, 01:Mem, 10:PC+2, 11:Imm
    input  wire [15:0] i_alu_result,
    input  wire [15:0] i_dmem_data,
    input  wire [15:0] i_pc_plus_2,
    input  wire [15:0] i_imm_data,
    output wire [15:0] o_wdata
);

    // L1階層: 16ビット幅の4入力マルチプレクサをインスタンス化
    // 各データソース（演算器、メモリ、プログラムカウンタ、即値生成器）を統合する
    writeback_mux_4to1_16bit u_mux_16bit (
        .i_sel (i_sel),
        .i_d0  (i_alu_result),
        .i_d1  (i_dmem_data),
        .i_d2  (i_pc_plus_2),
        .i_d3  (i_imm_data),
        .o_q   (o_wdata)
    );

endmodule