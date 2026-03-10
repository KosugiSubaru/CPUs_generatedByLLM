module imm_generator_mux4_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_y
);

    wire [15:0] w_m01;
    wire [15:0] w_m23;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux4
            // 下位セレクタ：sel[0]でd0/d1およびd2/d3を選択
            imm_generator_mux2 u_mux_01 (
                .i_sel (i_sel[0]),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .o_y   (w_m01[i])
            );
            imm_generator_mux2 u_mux_23 (
                .i_sel (i_sel[0]),
                .i_d0  (i_d2[i]),
                .i_d1  (i_d3[i]),
                .o_y   (w_m23[i])
            );
            // 上位セレクタ：sel[1]で最終結果を選択
            imm_generator_mux2 u_mux_final (
                .i_sel (i_sel[1]),
                .i_d0  (w_m01[i]),
                .i_d1  (w_m23[i]),
                .o_y   (o_y[i])
            );
        end
    endgenerate

endmodule