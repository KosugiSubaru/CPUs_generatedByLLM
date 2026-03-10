module register_file_16bit_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_en,
    input  wire [15:0] i_data,
    output reg  [15:0] o_data
);

    // 16ビットのレジスタ本体
    // 論理合成後の回路図で、1つのまとまった16ビット記憶ブロックとして視覚化される
    // 単位記憶要素として、非同期リセットと書き込み有効信号（EN）を持つ
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_data <= 16'h0000;
        end else if (i_en) begin
            o_data <= i_data;
        end
    end

endmodule