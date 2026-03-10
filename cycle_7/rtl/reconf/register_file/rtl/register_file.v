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

    wire [15:0]  w_reg_wen;
    wire [255:0] w_all_reg_data;

    // 書き込みデコーダ：どのレジスタに書き込むかを選択
    register_file_decoder_4to16 u_dec_write (
        .i_sel (i_rd_addr),
        .i_en  (i_rd_wen),
        .o_out (w_reg_wen)
    );

    // R0の処理：ISA定義に基づき常に0を返す（書き込み信号は無視される）
    assign w_all_reg_data[15:0] = 16'h0000;

    // R1からR15までの実体レジスタを生成
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_register_instances
            register_file_reg_16bit u_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (w_reg_wen[i]),
                .i_data  (i_rd_data),
                .o_data  (w_all_reg_data[i*16 +: 16])
            );
        end
    endgenerate

    // 読み出しポート1 (rs1)
    register_file_mux_16to1_16bit u_mux_rs1 (
        .i_sel      (i_rs1_addr),
        .i_all_data (w_all_reg_data),
        .o_out      (o_rs1_data)
    );

    // 読み出しポート2 (rs2)
    register_file_mux_16to1_16bit u_mux_rs2 (
        .i_sel      (i_rs2_addr),
        .i_all_data (w_all_reg_data),
        .o_out      (o_rs2_data)
    );

endmodule