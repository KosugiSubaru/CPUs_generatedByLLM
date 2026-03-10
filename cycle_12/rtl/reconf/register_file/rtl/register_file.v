module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    input  wire        i_reg_wen,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0] w_wen_bus;
    wire [15:0] w_reg_data [15:0];

    // 1. 書き込みデコーダのインスタンス化
    // どのレジスタに書き込むかを16本の独立した信号にデコードする
    register_file_decoder_4to16 u_decoder (
        .i_addr    (i_rd_addr),
        .i_wen     (i_reg_wen),
        .o_wen_bus (w_wen_bus)
    );

    // 2. レジスタセル群の構成
    // ISA定義に基づき、レジスタ0番は常に0を出力し、書き込みを無視する（定数接続）
    assign w_reg_data[0] = 16'h0000;

    // 1番から15番までのレジスタを構造的に並べる
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_reg_cells
            register_file_cell u_cell (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (w_wen_bus[i]),
                .i_data  (i_rd_data),
                .o_data  (w_reg_data[i])
            );
        end
    endgenerate

    // 3. 読み出しポート1 (RS1) のマルチプレクサ
    register_file_mux_16to1_16bit u_mux_rs1 (
        .i_sel (i_rs1_addr),
        .i_d0 (w_reg_data[0]),  .i_d1 (w_reg_data[1]),  .i_d2 (w_reg_data[2]),  .i_d3 (w_reg_data[3]),
        .i_d4 (w_reg_data[4]),  .i_d5 (w_reg_data[5]),  .i_d6 (w_reg_data[6]),  .i_d7 (w_reg_data[7]),
        .i_d8 (w_reg_data[8]),  .i_d9 (w_reg_data[9]),  .i_d10(w_reg_data[10]), .i_d11(w_reg_data[11]),
        .i_d12(w_reg_data[12]), .i_d13(w_reg_data[13]), .i_d14(w_reg_data[14]), .i_d15(w_reg_data[15]),
        .o_data (o_rs1_data)
    );

    // 4. 読み出しポート2 (RS2) のマルチプレクサ
    register_file_mux_16to1_16bit u_mux_rs2 (
        .i_sel (i_rs2_addr),
        .i_d0 (w_reg_data[0]),  .i_d1 (w_reg_data[1]),  .i_d2 (w_reg_data[2]),  .i_d3 (w_reg_data[3]),
        .i_d4 (w_reg_data[4]),  .i_d5 (w_reg_data[5]),  .i_d6 (w_reg_data[6]),  .i_d7 (w_reg_data[7]),
        .i_d8 (w_reg_data[8]),  .i_d9 (w_reg_data[9]),  .i_d10(w_reg_data[10]), .i_d11(w_reg_data[11]),
        .i_d12(w_reg_data[12]), .i_d13(w_reg_data[13]), .i_d14(w_reg_data[14]), .i_d15(w_reg_data[15]),
        .o_data (o_rs2_data)
    );

endmodule