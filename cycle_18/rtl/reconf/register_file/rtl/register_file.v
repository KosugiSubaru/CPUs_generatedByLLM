module register_file (
    input wire         i_clk,
    input wire         i_rst_n,
    input wire [3:0]   i_rs1_addr,
    input wire [3:0]   i_rs2_addr,
    input wire [3:0]   i_rd_addr,
    input wire [15:0]  i_rd_data,
    input wire         i_rd_we,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0]  w_rd_decode;
    wire [255:0] w_all_reg_data;

    // 書き込みアドレスのデコード
    register_file_decoder_4to16 u_decoder (
        .i_addr   (i_rd_addr),
        .o_decode (w_rd_decode)
    );

    // レジスタ0 (ゼロレジスタ: 常に0)
    register_file_reg_zero_16bit u_reg0 (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_we    (w_rd_decode[0] & i_rd_we),
        .i_d     (i_rd_data),
        .o_q     (w_all_reg_data[15:0])
    );

    // レジスタ1-15 (通常レジスタ)
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_registers
            register_file_reg_16bit u_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_we    (w_rd_decode[i] & i_rd_we),
                .i_d     (i_rd_data),
                .o_q     (w_all_reg_data[16*i +: 16])
            );
        end
    endgenerate

    // 読み出しポート1 (RS1)
    register_file_mux16_16bit u_mux_rs1 (
        .i_data_all (w_all_reg_data),
        .i_sel      (i_rs1_addr),
        .o_data     (o_rs1_data)
    );

    // 読み出しポート2 (RS2)
    register_file_mux16_16bit u_mux_rs2 (
        .i_data_all (w_all_reg_data),
        .i_sel      (i_rs2_addr),
        .o_data     (o_rs2_data)
    );

endmodule