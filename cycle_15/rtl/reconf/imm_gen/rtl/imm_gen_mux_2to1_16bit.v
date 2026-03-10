module imm_gen_mux_2to1_16bit (
    input  wire        i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    output wire [15:0] o_data
);

    // セレクト信号に基づき、16ビットのデータを選択する
    // 論理合成後の回路図において、16ビット並列の選択構造として視覚化される
    assign o_data = (i_sel) ? i_d1 : i_d0;

endmodule