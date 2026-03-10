module alu_mux_2to1_16bit (
    input  wire        i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    output wire [15:0] o_data
);

    // セレクト信号に基づき、2つの16ビット入力から1つを選択して出力する
    // 回路図上では、上位の8to1 MUXやバレルシフタを構成する基本ユニットとして視覚化される
    assign o_data = (i_sel == 1'b1) ? i_d1 : i_d0;

endmodule