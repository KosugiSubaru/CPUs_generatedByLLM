module program_counter_mux_4to1_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_data
);

    wire [15:0] w_stage1_out [1:0];

    // 2入力セレクタを組み合わせて4入力セレクタを構成する
    // ステージ1: 下位1ビット(i_sel[0])を用いて(d0,d1)および(d2,d3)から中間値を選択
    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_mux_stage1
            program_counter_mux_2to1_16bit u_mux_s1 (
                .i_sel  (i_sel[0]),
                .i_d0   ( (i == 0) ? i_d0 : i_d2 ),
                .i_d1   ( (i == 0) ? i_d1 : i_d3 ),
                .o_data (w_stage1_out[i])
            );
        end
    endgenerate

    // ステージ2: 上位1ビット(i_sel[1])を用いて最終的な出力を決定
    program_counter_mux_2to1_16bit u_mux_stage2 (
        .i_sel  (i_sel[1]),
        .i_d0   (w_stage1_out[0]),
        .i_d1   (w_stage1_out[1]),
        .o_data (o_data)
    );

endmodule