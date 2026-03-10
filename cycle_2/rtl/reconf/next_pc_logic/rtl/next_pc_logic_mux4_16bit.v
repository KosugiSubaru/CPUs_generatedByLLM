module next_pc_logic_mux4_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_y
);

    // 内部ワイヤ：1段目の選択結果を保持
    wire [15:0] w_stage1_low;
    wire [15:0] w_stage1_high;

    genvar i;

    // generate文を用いて、16ビット分並列に2入力MUXを組み合わせて4入力MUXを構成
    // 論理合成後の回路図で、2段のMUXツリーとして視覚化されるように実装
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux4_bits
            // 1段目：下位選択信号 i_sel[0] で d0/d1 と d2/d3 をそれぞれ選択
            next_pc_logic_mux2_1bit u_mux_s1_low (
                .i_sel (i_sel[0]),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .o_y   (w_stage1_low[i])
            );

            next_pc_logic_mux2_1bit u_mux_s1_high (
                .i_sel (i_sel[0]),
                .i_d0  (i_d2[i]),
                .i_d1  (i_d3[i]),
                .o_y   (w_stage1_high[i])
            );

            // 2段目：上位選択信号 i_sel[1] で最終的な1つを選択
            next_pc_logic_mux2_1bit u_mux_s2_final (
                .i_sel (i_sel[1]),
                .i_d0  (w_stage1_low[i]),
                .i_d1  (w_stage1_high[i]),
                .o_y   (o_y[i])
            );
        end
    endgenerate

endmodule