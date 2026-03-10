module reg_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rs1_addr,    // 読出レジスタ1アドレス
    input  wire [3:0]  i_rs2_addr,    // 読出レジスタ2アドレス
    input  wire [3:0]  i_rd_addr,     // 書込レジスタアドレス
    input  wire [15:0] i_rd_data,     // 書込データ
    input  wire        i_reg_wen,     // レジスタ書き込み有効信号
    output wire [15:0] o_rs1_data,    // レジスタ1出力
    output wire [15:0] o_rs2_data     // レジスタ2出力
);

    // 内部接続用ワイヤ
    wire [15:0]  w_reg_wen_vec;       // 個別レジスタ用書き込み有効信号
    wire [255:0] w_reg_all_data;      // 全16レジスタの値をフラットに結合した信号
    wire [7:0]   w_read_addr_bus;     // 読出アドレスをまとめたバス
    wire [31:0]  w_read_data_bus;     // 読出データをまとめたバス

    // 入力アドレスのバス化（generate用）
    assign w_read_addr_bus = {i_rs2_addr, i_rs1_addr};
    assign o_rs1_data = w_read_data_bus[15:0];
    assign o_rs2_data = w_read_data_bus[31:16];

    // 階層1: 書込アドレスのデコード
    // 4bitアドレスと全体有効信号から、16本の個別有効信号を生成
    reg_file_decoder_4to16 u_decoder (
        .i_addr (i_rd_addr),
        .i_wen  (i_reg_wen),
        .o_wen  (w_reg_wen_vec)
    );

    // 階層1: レジスタ本体（バンク）
    // 実体としてのレジスタ集合。内部でレジスタ0の0固定を実現。
    reg_file_bank_16 u_bank (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_wen_vec (w_reg_wen_vec),
        .i_wd      (i_rd_data),
        .o_rd_all  (w_reg_all_data)
    );

    // 階層1: 読出ポート
    // パタン構造化のため、RS1用とRS2用の2つのポートを一括で生成
    genvar p;
    generate
        for (p = 0; p < 2; p = p + 1) begin : read_ports
            reg_file_read_port_16bit u_port (
                .i_addr   (w_read_addr_bus[p*4 +: 4]),
                .i_rd_all (w_reg_all_data),
                .o_data   (w_read_data_bus[p*16 +: 16])
            );
        end
    endgenerate

endmodule