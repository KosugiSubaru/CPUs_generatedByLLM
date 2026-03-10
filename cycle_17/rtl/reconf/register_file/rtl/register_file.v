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

    wire [15:0] w_regs [15:0];
    genvar k;

    generate
        for (k = 0; k < 16; k = k + 1) begin : gen_rf_cells
            if (k == 0) begin : r0_zero
                // R0は常に0を出力し、書き込み不可（ISA定義に基づく）
                assign w_regs[k] = 16'd0;
            end else begin : rx_normal
                wire w_cell_en;
                // 書き込み許可信号かつデコード結果が一致した場合のみ有効
                assign w_cell_en = i_wen && (i_rd_addr == k[3:0]);

                register_file_cell_16bit u_reg_cell (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_en    (w_cell_en),
                    .i_data  (i_rd_data),
                    .o_data  (w_regs[k])
                );
            end
        end
    endgenerate

    // 読み出しポート1 (rs1用)
    register_file_mux16_16bit u_mux_rs1 (
        .i_r0(w_regs[0]),   .i_r1(w_regs[1]),   .i_r2(w_regs[2]),   .i_r3(w_regs[3]),
        .i_r4(w_regs[4]),   .i_r5(w_regs[5]),   .i_r6(w_regs[6]),   .i_r7(w_regs[7]),
        .i_r8(w_regs[8]),   .i_r9(w_regs[9]),   .i_r10(w_regs[10]), .i_r11(w_regs[11]),
        .i_r12(w_regs[12]), .i_r13(w_regs[13]), .i_r14(w_regs[14]), .i_r15(w_regs[15]),
        .i_sel(i_rs1_addr),
        .o_data(o_rs1_data)
    );

    // 読み出しポート2 (rs2用)
    register_file_mux16_16bit u_mux_rs2 (
        .i_r0(w_regs[0]),   .i_r1(w_regs[1]),   .i_r2(w_regs[2]),   .i_r3(w_regs[3]),
        .i_r4(w_regs[4]),   .i_r5(w_regs[5]),   .i_r6(w_regs[6]),   .i_r7(w_regs[7]),
        .i_r8(w_regs[8]),   .i_r9(w_regs[9]),   .i_r10(w_regs[10]), .i_r11(w_regs[11]),
        .i_r12(w_regs[12]), .i_r13(w_regs[13]), .i_r14(w_regs[14]), .i_r15(w_regs[15]),
        .i_sel(i_rs2_addr),
        .o_data(o_rs2_data)
    );

endmodule