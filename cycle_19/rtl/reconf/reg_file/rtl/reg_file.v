module reg_file (
    input  wire        i_clk,      // クロック信号
    input  wire        i_rst_n,    // 非同期リセット
    input  wire        i_wen,      // 書き込み有効信号
    input  wire [3:0]  i_rd_addr,  // 書き込みレジスタアドレス
    input  wire [15:0] i_rd_data,  // 書き込みデータ
    input  wire [3:0]  i_rs1_addr, // 読み出し1アドレス
    input  wire [3:0]  i_rs2_addr, // 読み出し2アドレス
    output wire [15:0] o_rs1_data, // 読み出し1データ
    output wire [15:0] o_rs2_data  // 読み出し2データ
);

    // 各レジスタセルの出力を受けるワイヤ群
    wire [15:0] w_regs [15:0];
    // 各レジスタセルへの書き込み有効信号
    wire [15:0] w_reg_wen;
    
    genvar i;

    // 16個のレジスタセルをインスタンス化
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_reg_array
            // R0(i==0)は常に書き込み不可、それ以外はアドレスが一致した時のみ書き込み
            assign w_reg_wen[i] = (i == 0) ? 1'b0 : (i_wen && (i_rd_addr == i[3:0]));

            reg_file_cell u_cell (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (w_reg_wen[i]),
                .i_data  (i_rd_data),
                .o_data  (w_regs[i])
            );
        end
    endgenerate

    // 読み出しポート1（rs1）用マルチプレクサ
    reg_file_mux u_mux_rs1 (
        .i_addr (i_rs1_addr),
        .i_r0(w_regs[0]),   .i_r1(w_regs[1]),   .i_r2(w_regs[2]),   .i_r3(w_regs[3]),
        .i_r4(w_regs[4]),   .i_r5(w_regs[5]),   .i_r6(w_regs[6]),   .i_r7(w_regs[7]),
        .i_r8(w_regs[8]),   .i_r9(w_regs[9]),   .i_r10(w_regs[10]), .i_r11(w_regs[11]),
        .i_r12(w_regs[12]), .i_r13(w_regs[13]), .i_r14(w_regs[14]), .i_r15(w_regs[15]),
        .o_data (o_rs1_data)
    );

    // 読み出しポート2（rs2）用マルチプレクサ
    reg_file_mux u_mux_rs2 (
        .i_addr (i_rs2_addr),
        .i_r0(w_regs[0]),   .i_r1(w_regs[1]),   .i_r2(w_regs[2]),   .i_r3(w_regs[3]),
        .i_r4(w_regs[4]),   .i_r5(w_regs[5]),   .i_r6(w_regs[6]),   .i_r7(w_regs[7]),
        .i_r8(w_regs[8]),   .i_r9(w_regs[9]),   .i_r10(w_regs[10]), .i_r11(w_regs[11]),
        .i_r12(w_regs[12]), .i_r13(w_regs[13]), .i_r14(w_regs[14]), .i_r15(w_regs[15]),
        .o_data (o_rs2_data)
    );

endmodule