module data_path_mux (
    input  wire        i_alu_src_b_sel, // 0:rs2, 1:imm
    input  wire [1:0]  i_reg_wdata_sel, // 0:ALU, 1:Mem, 2:PC+2
    input  wire [15:0] i_rs2_data,      // レジスタRS2からの読み出しデータ
    input  wire [15:0] i_imm_data,      // 生成された16ビット即値
    input  wire [15:0] i_alu_result,    // ALUの演算結果
    input  wire [15:0] i_mem_data,      // データメモリからの読み出しデータ
    input  wire [15:0] i_pc_plus_2,     // PC+2（リンク用戻りアドレス）
    output wire [15:0] o_alu_in_b,      // ALUの入力B端子へ
    output wire [15:0] o_reg_wdata      // レジスタファイルの書き込みデータ端子へ
);

    // --- 1. ALU入力選択ユニット (ALU Source-B) ---
    // 命令がRタイプかIタイプかに応じて、ALUの第2引数を切り替える。
    // 内部で1bitセレクタを16個並列化して構成される。
    data_path_mux_nbit_alu_src u_alu_src_sel (
        .i_sel   (i_alu_src_b_sel),
        .i_data0 (i_rs2_data),
        .i_data1 (i_imm_data),
        .o_data  (o_alu_in_b)
    );

    // --- 2. レジスタ書き戻し選択ユニット (Write-Back) ---
    // 命令の目的（計算、メモリ参照、ジャンプ）に応じてレジスタへの保存データを選択。
    // 内部で1bitセレクタを16個並列化して構成される。
    data_path_mux_nbit_reg_wdata u_reg_wdata_sel (
        .i_sel   (i_reg_wdata_sel),
        .i_data0 (i_alu_result),
        .i_data1 (i_mem_data),
        .i_data2 (i_pc_plus_2),
        .i_data3 (16'h0000), // 未使用(Reserved)
        .o_data  (o_reg_wdata)
    );

endmodule