module register_file_bit_cell (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_wen,
    input  wire i_d,
    output reg  o_q
);

    // 書き込み有効信号（wen）付きの1ビットDフリップフロップ
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else if (i_wen) begin
            o_q <= i_d;
        end
    end

endmodule