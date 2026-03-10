module writeback_mux_1bit_4to1 (
    input  wire [1:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    output wire       o_data
);

    wire w_st1_0; // ステージ1 中間出力0
    wire w_st1_1; // ステージ1 中間出力1

    // 2進ツリー構造による1ビット4入力セレクタの構成
    // ステージ1: 下位ビット(sel[0])を用いて2組の入力から選択
    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_mux_stage1
            if (i == 0) begin : mux_low
                writeback_mux_1bit_2to1 u_mux_s1 (
                    .i_sel  (i_sel[0]),
                    .i_d0   (i_d0),
                    .i_d1   (i_d1),
                    .o_data (w_st1_0)
                );
            end else begin : mux_high
                writeback_mux_1bit_2to1 u_mux_s1 (
                    .i_sel  (i_sel[0]),
                    .i_d0   (i_d2),
                    .i_d1   (i_d3),
                    .o_data (w_st1_1)
                );
            end
        end
    endgenerate

    // ステージ2: 上位ビット(sel[1])を用いて最終的な出力を決定
    writeback_mux_1bit_2to1 u_mux_stage2 (
        .i_sel  (i_sel[1]),
        .i_d0   (w_st1_0),
        .i_d1   (w_st1_1),
        .o_data (o_data)
    );

endmodule