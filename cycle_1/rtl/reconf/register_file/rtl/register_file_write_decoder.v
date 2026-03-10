module register_file_write_decoder (
    input  wire [3:0]  i_addr,
    input  wire        i_wen,
    output wire [15:0] o_reg_wens
);

    // ゼロレジスタ (R0) への書き込み信号は常に無効化 (ISA定義: 常に0、書き込み不可)
    assign o_reg_wens[0]  = 1'b0;

    // 各レジスタ番号と入力アドレスの一致を判定し、書き込み有効信号を分配
    // 回路図上で16本の独立したイネーブル線として視覚化される
    assign o_reg_wens[1]  = (i_addr == 4'h1)  ? i_wen : 1'b0;
    assign o_reg_wens[2]  = (i_addr == 4'h2)  ? i_wen : 1'b0;
    assign o_reg_wens[3]  = (i_addr == 4'h3)  ? i_wen : 1'b0;
    assign o_reg_wens[4]  = (i_addr == 4'h4)  ? i_wen : 1'b0;
    assign o_reg_wens[5]  = (i_addr == 4'h5)  ? i_wen : 1'b0;
    assign o_reg_wens[6]  = (i_addr == 4'h6)  ? i_wen : 1'b0;
    assign o_reg_wens[7]  = (i_addr == 4'h7)  ? i_wen : 1'b0;
    assign o_reg_wens[8]  = (i_addr == 4'h8)  ? i_wen : 1'b0;
    assign o_reg_wens[9]  = (i_addr == 4'h9)  ? i_wen : 1'b0;
    assign o_reg_wens[10] = (i_addr == 4'ha)  ? i_wen : 1'b0;
    assign o_reg_wens[11] = (i_addr == 4'hb)  ? i_wen : 1'b0;
    assign o_reg_wens[12] = (i_addr == 4'hc)  ? i_wen : 1'b0;
    assign o_reg_wens[13] = (i_addr == 4'hd)  ? i_wen : 1'b0;
    assign o_reg_wens[14] = (i_addr == 4'he)  ? i_wen : 1'b0;
    assign o_reg_wens[15] = (i_addr == 4'hf)  ? i_wen : 1'b0;

endmodule