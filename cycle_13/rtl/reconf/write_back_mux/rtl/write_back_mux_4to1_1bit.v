module write_back_mux_4to1_1bit (
    input  wire [1:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    output wire       o_data
);

    wire w_mux_low;
    wire w_mux_high;

    // 2入力1ビットMUXを3つ組み合わせることで、4入力選択回路を構造化する
    // i_sel[0] で各ペアを選択し、i_sel[1] で最終的な出力を決定する

    write_back_mux_2to1_1bit u_mux_low (
        .i_sel  (i_sel[0]),
        .i_d0   (i_d0),
        .i_d1   (i_d1),
        .o_data (w_mux_low)
    );

    write_back_mux_2to1_1bit u_mux_high (
        .i_sel  (i_sel[0]),
        .i_d0   (i_d2),
        .i_d1   (i_d3),
        .o_data (w_mux_high)
    );

    write_back_mux_2to1_1bit u_mux_final (
        .i_sel  (i_sel[1]),
        .i_d0   (w_mux_low),
        .i_d1   (w_mux_high),
        .o_data (o_data)
    );

endmodule