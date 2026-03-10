module wb_mux (
    input  wire [15:0] i_alu_result,
    input  wire [15:0] i_mem_data,
    input  wire [15:0] i_pc_plus_2,
    input  wire [15:0] i_imm_data,
    input  wire [1:0]  i_result_src,
    output wire [15:0] o_wb_data
);

    // 16ビット幅の4入力マルチプレクサをインスタンス化
    // ResultSrc信号に基づき、レジスタに書き戻すデータソースを切り替える
    wb_mux_4to1_16bit u_mux_16bit (
        .i_data0 (i_alu_result),
        .i_data1 (i_mem_data),
        .i_data2 (i_pc_plus_2),
        .i_data3 (i_imm_data),
        .i_sel   (i_result_src),
        .o_data  (o_wb_data)
    );

endmodule