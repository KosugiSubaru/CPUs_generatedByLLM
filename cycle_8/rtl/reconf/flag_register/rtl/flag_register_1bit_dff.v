module flag_register_1bit_dff (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_en,
    input  wire i_d,
    output reg  o_q
);

    // 1ビットのフラグ記憶素子
    // 論理合成後の回路図において、独立した1ビットのフリップフロップとして視覚化される
    // 書き込み有効信号(i_en)により、特定の命令（演算命令）時のみフラグが更新される動作を実現
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else if (i_en) begin
            o_q <= i_d;
        end
    end

endmodule