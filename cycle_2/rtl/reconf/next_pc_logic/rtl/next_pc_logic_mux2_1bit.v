module next_pc_logic_mux2_1bit (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_y
);

    // 2入力マルチプレクサの最小構成論理
    // i_selが0のときi_d0を選択、1のときi_d1を選択する
    assign o_y = i_sel ? i_d1 : i_d0;

endmodule