module immediate_generator_mux4_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_q
);

    wire [15:0] w_mux_low;
    wire [15:0] w_mux_high;
    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux4_tree
            // 1段目: 下位2つの入力から選択
            immediate_generator_mux2_1bit u_mux_low (
                .i_sel (i_sel[0]),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .o_q   (w_mux_low[i])
            );

            // 1段目: 上位2つの入力から選択
            immediate_generator_mux2_1bit u_mux_high (
                .i_sel (i_sel[0]),
                .i_d0  (i_d2[i]),
                .i_d1  (i_d3[i]),
                .o_q   (w_mux_high[i])
            );

            // 2段目: 1段目の結果から最終的な出力を選択
            immediate_generator_mux2_1bit u_mux_final (
                .i_sel (i_sel[1]),
                .i_d0  (w_mux_low[i]),
                .i_d1  (w_mux_high[i]),
                .o_q   (o_q[i])
            );
        end
    endgenerate

endmodule