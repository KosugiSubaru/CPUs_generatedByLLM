module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_reg_wen,      // レジスタ書き込み有効
    input  wire [3:0]  i_rd_addr,      // 書き込み先レジスタ番号 (rd)
    input  wire [15:0] i_rd_data,      // 書き込みデータ
    input  wire [3:0]  i_rs1_addr,     // 読み出しレジスタ番号1 (rs1)
    input  wire [3:0]  i_rs2_addr,     // 読み出しレジスタ番号2 (rs2)
    output wire [15:0] o_rs1_data,     // 読み出しデータ1
    output wire [15:0] o_rs2_data      // 読み出しデータ2
);

    // 内部配線: デコーダから各レジスタセルへの書き込み有効信号 (16本)
    wire [15:0] w_reg_enables;

    // 内部配線: ストレージからMUXへ全レジスタの値を送るためのバス (16ビット×16本 = 256ビット)
    wire [255:0] w_all_regs_flattened;

    // -------------------------------------------------------------------------
    // 1. 書き込みアドレスデコーダ
    // -------------------------------------------------------------------------
    register_file_write_decoder u_write_decoder (
        .i_addr    (i_rd_addr),
        .i_wen     (i_reg_wen),
        .o_enables (w_reg_enables)
    );

    // -------------------------------------------------------------------------
    // 2. レジスタストレージ (16個のレジスタ本体)
    // -------------------------------------------------------------------------
    register_file_storage u_storage (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_enables  (w_reg_enables),
        .i_data     (i_rd_data),
        .o_all_data (w_all_regs_flattened)
    );

    // -------------------------------------------------------------------------
    // 3. 読み出しマルチプレクサ (Port 1)
    // -------------------------------------------------------------------------
    register_file_mux_16to1 u_mux_rs1 (
        .i_all_data (w_all_regs_flattened),
        .i_sel      (i_rs1_addr),
        .o_data     (o_rs1_data)
    );

    // -------------------------------------------------------------------------
    // 4. 読み出しマルチプレクサ (Port 2)
    // -------------------------------------------------------------------------
    register_file_mux_16to1 u_mux_rs2 (
        .i_all_data (w_all_regs_flattened),
        .i_sel      (i_rs2_addr),
        .o_data     (o_rs2_data)
    );

endmodule