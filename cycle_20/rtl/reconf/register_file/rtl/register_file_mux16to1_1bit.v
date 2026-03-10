module register_file_mux16to1_1bit (
    input  wire [3:0]  i_select,
    input  wire [15:0] i_data,
    output wire        o_data
);

    // 16入力のうち、i_selectで指定された1ビットを選択して出力する
    // 論理合成において16対1のマルチプレクサとして視覚化される
    assign o_data = i_data[i_select];

endmodule