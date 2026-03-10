module pc_logic_mux2to1_1bit (
    input  wire i_sel,
    input  wire i_in0,
    input  wire i_in1,
    output wire o_out
);

    // 選択信号に基づき、2つの入力から1つを選択して出力
    // 論理合成において、データパスを切り替える最小単位のセレクタとして視覚化される
    assign o_out = (i_sel) ? i_in1 : i_in0;

endmodule