module flag_reg_unit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_en,   // フラグ更新有効信号
    input  wire i_d,    // 新しいフラグ値
    output wire o_q     // 現在保持されているフラグ値
);

    wire w_dff_in;

    // セレクタにより、Enableが1なら新しい値(i_d)を、0なら現在の値(o_q)を選択
    // これによりレジスタの値を「更新」するか「維持」するかを決定する
    flag_reg_mux2 u_mux (
        .i_sel (i_en),
        .i_d0  (o_q),
        .i_d1  (i_d),
        .o_data(w_dff_in)
    );

    // クロック同期で選択された値を保持する
    flag_reg_dff u_dff (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_d    (w_dff_in),
        .o_q    (o_q)
    );

endmodule