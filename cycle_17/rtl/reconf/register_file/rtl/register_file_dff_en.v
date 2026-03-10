module register_file_dff_en (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_en,
    input  wire i_d,
    output reg  o_q
);

    // 書き込み許可(Enable)信号付きの1ビットD-フリップフロップ
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else if (i_en) begin
            o_q <= i_d;
        end
    end

endmodule