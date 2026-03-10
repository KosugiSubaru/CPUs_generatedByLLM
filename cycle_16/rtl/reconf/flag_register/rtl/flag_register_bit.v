module flag_register_bit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_d,
    output reg  o_q
);

    // フラグ1ビット分を保持するD-フリップフロップ
    // 非同期リセット（負論理）付き
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else begin
            o_q <= i_d;
        end
    end

endmodule