module mem_ctrl (
    input  wire [15:0] i_rs1_data,        // 基底アドレスとなるレジスタ値
    input  wire [15:0] i_rs2_data,        // メモリへ書き込むデータ元
    input  wire [15:0] i_imm,             // オフセット即値
    input  wire        i_dmem_wen,        // 制御ユニットからの書き込み有効信号
    input  wire [15:0] i_data_from_dmem,  // データメモリ(dmem)からの読み出し値
    output wire [15:0] o_addr_to_dmem,    // データメモリ(dmem)へのアドレス信号
    output wire [15:0] o_data_to_dmem,    // データメモリ(dmem)への書き込みデータ
    output wire        o_dmem_wen,        // データメモリ(dmem)への書き込み有効
    output wire [15:0] o_load_data        // レジスタ(rd)へ書き戻すロードデータ
);

    // 階層1: 実効アドレス計算ブロック
    // ISA定義: Mem[rs1 + imm] に基づき、アクセス先アドレスを計算
    mem_ctrl_adder_16bit u_addr_calc (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (o_addr_to_dmem)
    );

    // 階層1: 書き込みデータ出力バッファ
    // CPU内部のデータをデータメモリの入力ポートへ整列させて出力
    mem_ctrl_buffer_16bit u_data_buf (
        .i_in  (i_rs2_data),
        .o_out (o_data_to_dmem)
    );

    // 制御信号のバイパス
    assign o_dmem_wen = i_dmem_wen;

    // 読み出しデータのバイパス
    // load命令時にメモリからの値をそのままCPU内部のデータパスへ供給
    assign o_load_data = i_data_from_dmem;

endmodule