module reg_file_mux_16to1_1bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_in,
    output wire        o_out
);

    // 16個の入力ビットから、4bitのアドレス信号に基づいて1つを選択する
    // 論理合成後の回路図で、読出ポートのデータ選択の最小単位として視覚化される
    assign o_out = i_in[i_sel];

endmodule