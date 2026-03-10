module flag_reg_mux2 (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_data
);

    // セレクト信号に基づき、2つの1ビット入力から1つを選択して出力する
    // フラグ更新有効信号(Enable)により、現状維持(d0)か新規取込(d1)かを切り替える
    assign o_data = (i_sel == 1'b1) ? i_d1 : i_d0;

endmodule