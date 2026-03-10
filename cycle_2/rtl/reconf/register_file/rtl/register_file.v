module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,         // レジスタ書き込み有効信号
    input  wire [3:0]  i_rd_addr,     // 書き込みレジスタ番号
    input  wire [15:0] i_rd_data,     // 書き込みデータ
    input  wire [3:0]  i_rs1_addr,    // 読み出しレジスタ番号1
    input  wire [3:0]  i_rs2_addr,    // 読み出しレジスタ番号2
    output wire [15:0] o_rs1_data,    // 読み出しデータ1
    output wire [15:0] o_rs2_data     // 読み出しデータ2
);

    // 内部ワイヤ定義
    // 16ビット×16本のデータをフラットな256ビットバスとして伝搬
    wire [255:0] w_reg_data_bus;
    // デコードされた16本の書き込み有効信号
    wire [15:0]  w_reg_wen_bus;

    // --- 1. 書き込みデコード部 (Write Decoder) ---
    // アドレスと全体有効信号を組み合わせ、各レジスタ個別の有効信号を生成
    register_file_decode_4to16 u_decoder (
        .i_addr (i_rd_addr),
        .i_wen  (i_wen),
        .o_decode_en (w_reg_wen_bus)
    );

    // --- 2. レジスタバンク部 (Register Bank) ---
    // 16個の16bitレジスタを保持する記憶部
    // R0は内部で常に0を出力するように構成されている
    register_file_cell_bank u_cell_bank (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_wen_bus  (w_reg_wen_bus),
        .i_data     (i_rd_data),
        .o_data_bus (w_reg_data_bus)
    );

    // --- 3. 読み出し選択部 ポート1 (Read MUX 1) ---
    // rs1_addrに基づき、16個のデータから1つを選択
    register_file_mux16_16bit u_mux_rs1 (
        .i_data_bus (w_reg_data_bus),
        .i_sel      (i_rs1_addr),
        .o_data     (o_rs1_data)
    );

    // --- 4. 読み出し選択部 ポート2 (Read MUX 2) ---
    // rs2_addrに基づき、16個のデータから1つを選択
    register_file_mux16_16bit u_mux_rs2 (
        .i_data_bus (w_reg_data_bus),
        .i_sel      (i_rs2_addr),
        .o_data     (o_rs2_data)
    );

endmodule