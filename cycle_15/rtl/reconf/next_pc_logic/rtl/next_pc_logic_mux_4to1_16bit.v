module next_pc_logic_mux_4to1_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_data
);

    wire [15:0] w_st1_0; // ステージ1 中間出力0
    wire [15:0] w_st1_1; // ステージ1 中間出力1

    // 2進ツリー構造による4入力セレクタの構成
    // ステージ1: 下位ビット(sel[0])を用いて2組の入力から中間出力を選択
    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_mux_stage1
            if (i == 0) begin : mux_low
                next_pc_logic_mux_2to1_16bit u_mux_s1 (
                    .i_sel  (i_sel[0]),
                    .i_d0   (i_d0),
                    .i_d1   (i_d1),
                    .o_data (w_st1_0)
                );
            end else begin : mux_high
                next_pc_logic_mux_2to1_16bit u_mux_s1 (
                    .i_sel  (i_sel[0]),
                    .i_d0   (i_d2),
                    .i_d1   (i_d3),
                    .o_data (w_st1_1)
                );
            end
        end
    endgenerate

    // ステージ2: 上位ビット(sel[1])を用いて最終的な出力を決定
    next_pc_logic_mux_2to1_16bit u_mux_stage2 (
        .i_sel  (i_sel[1]),
        .i_d0   (w_st1_0),
        .i_d1   (w_st1_1),
        .o_data (o_data)
    );

endmodule