module datapath_mux_4to1_1bit (
    input  wire [1:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    output wire       o_y
);

    wire w_low;
    wire w_high;

    // 1段目セレクタ：下位選択ビット(i_sel[0])でd0/d1およびd2/d3を選択
    datapath_mux_2to1_1bit u_mux_low (
        .i_sel (i_sel[0]),
        .i_d0  (i_d0),
        .i_d1  (i_d1),
        .o_y   (w_low)
    );

    datapath_mux_2to1_1bit u_mux_high (
        .i_sel (i_sel[0]),
        .i_d0  (i_d2),
        .i_d1  (i_d3),
        .o_y   (w_high)
    );

    // 2段目セレクタ：上位選択ビット(i_sel[1])で最終結果を選択
    datapath_mux_2to1_1bit u_mux_final (
        .i_sel (i_sel[1]),
        .i_d0  (w_low),
        .i_d1  (w_high),
        .o_y   (o_y)
    );

endmodule