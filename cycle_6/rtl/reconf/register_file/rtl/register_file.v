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

    // 内部ワイヤ：書き込み有効信号(1-hot)
    wire [15:0] w_we_onehot;
    // 内部ワイヤ：全レジスタの出力（16ビット×16個 = 256ビット）
    wire [255:0] w_all_regs;

    // デコーダ：書き込み先アドレスを1-hotの有効信号に変換
    register_file_decoder_4to16 u_decoder (
        .i_addr (i_rd_addr),
        .i_en   (i_wen),
        .o_dec  (w_we_onehot)
    );

    // R0の特殊扱い：常に0を出力
    assign w_all_regs[15:0] = 16'h0000;

    // R1からR15までのレジスタ実体を生成
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_registers
            register_file_reg_16bit u_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (w_we_onehot[i]),
                .i_d     (i_rd_data),
                .o_q     (w_all_regs[i*16 +: 16])
            );
        end
    endgenerate

    // 読み出しMUX (rs1ポート)
    register_file_mux_16to1_16bit u_mux_rs1 (
        .i_sel  (i_rs1_addr),
        .i_data (w_all_regs),
        .o_y    (o_rs1_data)
    );

    // 読み出しMUX (rs2ポート)
    register_file_mux_16to1_16bit u_mux_rs2 (
        .i_sel  (i_rs2_addr),
        .i_data (w_all_regs),
        .o_y    (o_rs2_data)
    );

endmodule