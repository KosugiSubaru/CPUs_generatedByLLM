module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    input  wire        i_rd_wen,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0]  w_reg_wens;
    wire [255:0] w_all_regs_data;

    // 1. 書き込みデコーダのインスタンス化
    // どのレジスタに書き込むかを16本の独立した信号にデコード
    register_file_write_decoder u_write_decoder (
        .i_addr     (i_rd_addr),
        .i_wen      (i_rd_wen),
        .o_reg_wens (w_reg_wens)
    );

    // 2. 16個のレジスタ（ワードユニット）のインスタンス化
    genvar r;
    generate
        for (r = 0; r < 16; r = r + 1) begin : gen_regs
            wire [15:0] w_single_reg_out;

            // 各レジスタユニット
            // R0の場合、w_reg_wens[0]はデコーダ内部で常に0に固定されている
            register_file_word_unit u_word_unit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (w_reg_wens[r]),
                .i_data  (i_rd_data),
                .o_data  (w_single_reg_out)
            );

            // 読み出しMUXに渡すために、各レジスタ出力を1本の大きなバス(256bit)に統合
            // 回路図上で全レジスタからMUXへ配線が伸びる様子を視覚化
            assign w_all_regs_data[r*16 +: 16] = (r == 0) ? 16'h0000 : w_single_reg_out;
        end
    endgenerate

    // 3. 読み出しポート1 (RS1) のMUX
    register_file_mux_16bit_16to1 u_mux_rs1 (
        .i_sel           (i_rs1_addr),
        .i_all_regs_data (w_all_regs_data),
        .o_data          (o_rs1_data)
    );

    // 4. 読み出しポート2 (RS2) のMUX
    register_file_mux_16bit_16to1 u_mux_rs2 (
        .i_sel           (i_rs2_addr),
        .i_all_regs_data (w_all_regs_data),
        .o_data          (o_rs2_data)
    );

endmodule