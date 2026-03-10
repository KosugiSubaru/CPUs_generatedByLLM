module imm_gen_mux4_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_y
);

    // 1段目の選択結果を保持するワイヤ
    wire [15:0] w_low_bits;
    wire [15:0] w_high_bits;

    genvar i;

    // 各ビット(0-15)に対して2入力MUXを組み合わせて4入力MUXを構成
    // 回路図上でツリー構造として視覚化されるように実装
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_tree
            // 1段目: sel[0]を用いて d0/d1 および d2/d3 を選択
            imm_gen_mux2 u_mux_low (
                .i_sel (i_sel[0]),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .o_y   (w_low_bits[i])
            );

            imm_gen_mux2 u_mux_high (
                .i_sel (i_sel[0]),
                .i_d0  (i_d2[i]),
                .i_d1  (i_d3[i]),
                .o_y   (w_high_bits[i])
            );

            // 2段目: sel[1]を用いて最終的な1つを選択
            imm_gen_mux2 u_mux_final (
                .i_sel (i_sel[1]),
                .i_d0  (w_low_bits[i]),
                .i_d1  (w_high_bits[i]),
                .o_y   (o_y[i])
            );
        end
    endgenerate

endmodule