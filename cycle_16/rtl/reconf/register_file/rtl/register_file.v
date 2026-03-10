module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    input  wire        i_rd_wen,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0]  w_rd_dec_onehot;
    wire [255:0] w_all_reg_data;
    wire [7:0]   w_read_addr_bus;
    wire [31:0]  w_read_data_bus;

    // パタン構造化のための信号統合
    assign w_read_addr_bus = {i_rs2_addr, i_rs1_addr};
    assign o_rs1_data = w_read_data_bus[15:0];
    assign o_rs2_data = w_read_data_bus[31:16];

    // L1: 書き込みアドレスデコーダー (4bit -> 16bit One-hot)
    register_file_decoder_4to16 u_decoder (
        .i_addr (i_rd_addr),
        .o_dec  (w_rd_dec_onehot)
    );

    // L1: レジスタセル配列 (R0-R15の保持、256bitバス出力)
    register_file_cell_array u_cell_array (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_wen      (i_rd_wen),
        .i_sel_onehot (w_rd_dec_onehot),
        .i_data     (i_rd_data),
        .o_all_data (w_all_reg_data)
    );

    // L1: 読み出しマルチプレクサ (2つの読み出しポートを構造化して生成)
    genvar p;
    generate
        for (p = 0; p < 2; p = p + 1) begin : gen_read_ports
            register_file_mux_16to1_16bit u_mux (
                .i_sel      (w_read_addr_bus[p*4 +: 4]),
                .i_data_bus (w_all_reg_data),
                .o_data     (w_read_data_bus[p*16 +: 16])
            );
        end
    endgenerate

endmodule