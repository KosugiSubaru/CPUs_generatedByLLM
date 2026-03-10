module datapath_mux (
    input  wire        i_alu_src_b,    // ALU入力Bの選択信号 (0:rs2, 1:imm)
    input  wire [1:0]  i_reg_src,      // レジスタ書き戻しデータの選択信号
    input  wire [15:0] i_rs2_data,     // レジスタからのrs2データ
    input  wire [15:0] i_imm_data,     // ImmGenからの符号拡張済み即値
    input  wire [15:0] i_alu_res,      // ALUの演算結果
    input  wire [15:0] i_mem_data,     // データメモリからの読み出しデータ
    input  wire [15:0] i_pc_plus_2,    // PC+2 (Link用アドレス)
    output wire [15:0] o_alu_input_b,  // ALUの第2入力へ
    output wire [15:0] o_rd_data       // レジスタファイルの書き込みデータへ
);

    // 1. ALU入力B選択マルチプレクサ (2入力16ビット)
    // addi, load, store, jalr 等で即値を選択する経路を視覚化
    datapath_mux_2to1_16bit u_mux_alu_b (
        .i_sel (i_alu_src_b),
        .i_d0  (i_rs2_data),
        .i_d1  (i_imm_data),
        .o_y   (o_alu_input_b)
    );

    // 2. レジスタ書き戻しデータ選択マルチプレクサ (4入力16ビット)
    // 00: ALU結果 (通常の演算)
    // 01: メモリデータ (load命令)
    // 10: PC+2 (jal, jalr命令)
    // 11: 即値データ (loadi命令)
    datapath_mux_4to1_16bit u_mux_wb_data (
        .i_sel (i_reg_src),
        .i_d0  (i_alu_res),
        .i_d1  (i_mem_data),
        .i_d2  (i_pc_plus_2),
        .i_d3  (i_imm_data),
        .o_y   (o_rd_data)
    );

endmodule