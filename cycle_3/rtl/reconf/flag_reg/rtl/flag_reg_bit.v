module flag_reg_bit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_wen,
    input  wire i_d,
    output wire o_q
);

    reg r_data;

    // クロック同期で1ビットのフラグ状態を保持するレジスタ
    // 更新有効信号(i_wen)がハイの時のみ、入力データを取り込む
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_data <= 1'b0;
        end else if (i_wen) begin
            r_data <= i_d;
        end
    end

    assign o_q = r_data;

endmodule