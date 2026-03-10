module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0]  w_reg_enables;
    wire [255:0] w_reg_data_bus;

    // 書き込みデコーダ：rdアドレスと書き込み有効信号から、各レジスタへの個別Enable信号を生成
    register_file_decoder_4to16 u_decoder (
        .i_en       (i_wen),
        .i_addr     (i_rd_addr),
        .o_enables  (w_reg_enables)
    );

    // レジスタ配列：16個のレジスタを保持し、全レジスタの値をバスとして出力
    register_file_array u_array (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_enables  (w_reg_enables),
        .i_data     (i_rd_data),
        .o_data_bus (w_reg_data_bus)
    );

    // 読み出しポート1：rs1アドレスに基づいてバスからデータを選択
    register_file_mux_16to1 u_mux_rs1 (
        .i_data_bus (w_reg_data_bus),
        .i_sel      (i_rs1_addr),
        .o_data     (o_rs1_data)
    );

    // 読み出しポート2：rs2アドレスに基づいてバスからデータを選択
    register_file_mux_16to1 u_mux_rs2 (
        .i_data_bus (w_reg_data_bus),
        .i_sel      (i_rs2_addr),
        .o_data     (o_rs2_data)
    );

endmodule