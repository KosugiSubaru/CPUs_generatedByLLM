module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    input  wire        i_wen,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0]  w_dec_rd_en;
    wire [255:0] w_all_regs_data;

    // 書き込みデコーダ：rd番のみ1にする
    register_file_decoder_4to16 u_dec_rd (
        .i_addr    (i_rd_addr),
        .o_decoded (w_dec_rd_en)
    );

    // レジスタ0番：ISA定義により常に0を返す
    // 構造を視覚化するためインスタンス化するが、入力と出力を0に固定
    register_file_reg_16bit u_reg_0 (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_wen   (1'b0),
        .i_data  (16'h0000),
        .o_data  ()
    );
    assign w_all_regs_data[15:0] = 16'h0000;

    // レジスタ1番〜15番：generate文によるパターン展開
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : g_rf_regs
            register_file_reg_16bit u_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (w_dec_rd_en[i] & i_wen),
                .i_data  (i_rd_data),
                .o_data  (w_all_regs_data[16*(i+1)-1 : 16*i])
            );
        end
    endgenerate

    // 読み出しポート1：rs1選択用MUX
    register_file_mux16to1_16bit u_mux_rs1 (
        .i_select (i_rs1_addr),
        .i_data   (w_all_regs_data),
        .o_data   (o_rs1_data)
    );

    // 読み出しポート2：rs2選択用MUX
    register_file_mux16to1_16bit u_mux_rs2 (
        .i_select (i_rs2_addr),
        .i_data   (w_all_regs_data),
        .o_data   (o_rs2_data)
    );

endmodule