module pc_reg_mux4_1bit (
    input  wire [1:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    output wire       o_data
);

    wire w_mux_low;
    wire w_mux_high;

    // 2入力MUXを組み合わせて4入力MUXを構成（構造化パターン）
    pc_reg_mux2_1bit u_mux_low (
        .i_sel  (i_sel[0]),
        .i_d0   (i_d0),
        .i_d1   (i_d1),
        .o_data (w_mux_low)
    );

    pc_reg_mux2_1bit u_mux_high (
        .i_sel  (i_sel[0]),
        .i_d0   (i_d2),
        .i_d1   (i_d3),
        .o_data (w_mux_high)
    );

    pc_reg_mux2_1bit u_mux_out (
        .i_sel  (i_sel[1]),
        .i_d0   (w_mux_low),
        .i_d1   (w_mux_high),
        .o_data (o_data)
    );

endmodule