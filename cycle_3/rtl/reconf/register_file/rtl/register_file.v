module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0]  w_decode_lines;
    wire [255:0] w_all_reg_data; // 16bit * 16reg = 256bit packed data

    // 書き込みアドレス(rd)を16本のデコード信号へ変換
    register_file_decoder_4to16 u_decoder (
        .i_addr   (i_rd_addr),
        .o_decode (w_decode_lines)
    );

    // R0: ゼロレジスタ (常に0を出力、書き込み不可)
    register_file_zero_reg_16bit u_reg_0 (
        .o_q (w_all_reg_data[15:0])
    );

    // R1～R15: 汎用レジスタのインスタンス化
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_registers
            // 各レジスタの書き込み許可条件: 全体の書き込み許可(i_wen) かつ デコード一致
            register_file_reg_16bit u_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (i_wen & w_decode_lines[i]),
                .i_d     (i_rd_data),
                .o_q     (w_all_reg_data[16*i +: 16])
            );
        end
    endgenerate

    // 読み出しポート1 (rs1) のマルチプレクサ
    register_file_mux_16to1_16bit u_mux_rs1 (
        .i_data (w_all_reg_data),
        .i_sel  (i_rs1_addr),
        .o_q    (o_rs1_data)
    );

    // 読み出しポート2 (rs2) のマルチプレクサ
    register_file_mux_16to1_16bit u_mux_rs2 (
        .i_data (w_all_reg_data),
        .i_sel  (i_rs2_addr),
        .o_q    (o_rs2_data)
    );

endmodule