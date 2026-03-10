module alu_mux_8to1_16bit (
    input  wire [2:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    input  wire [15:0] i_d4,
    input  wire [15:0] i_d5,
    input  wire [15:0] i_d6,
    input  wire [15:0] i_d7,
    output wire [15:0] o_data
);

    // 階層的なMUX構造（2進ツリー）のための中間ワイヤ
    wire [15:0] w_st1 [3:0]; // ステージ1出力
    wire [15:0] w_st2 [1:0]; // ステージ2出力

    genvar i;

    // ステージ1: 8個の入力から4個を選択 (sel[0]を使用)
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_mux_stage1
            wire [15:0] w_in0;
            wire [15:0] w_in1;

            if (i == 0) begin
                assign w_in0 = i_d0;
                assign w_in1 = i_d1;
            end else if (i == 1) begin
                assign w_in0 = i_d2;
                assign w_in1 = i_d3;
            end else if (i == 2) begin
                assign w_in0 = i_d4;
                assign w_in1 = i_d5;
            end else begin
                assign w_in0 = i_d6;
                assign w_in1 = i_d7;
            end

            alu_mux_2to1_16bit u_mux_s1 (
                .i_sel  (i_sel[0]),
                .i_d0   (w_in0),
                .i_d1   (w_in1),
                .o_data (w_st1[i])
            );
        end
    endgenerate

    // ステージ2: 4個の信号から2個を選択 (sel[1]を使用)
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_mux_stage2
            alu_mux_2to1_16bit u_mux_s2 (
                .i_sel  (i_sel[1]),
                .i_d0   (w_st1[i*2]),
                .i_d1   (w_st1[i*2+1]),
                .o_data (w_st2[i])
            );
        end
    endgenerate

    // ステージ3: 最終的な1出力を決定 (sel[2]を使用)
    alu_mux_2to1_16bit u_mux_stage3 (
        .i_sel  (i_sel[2]),
        .i_d0   (w_st2[0]),
        .i_d1   (w_st2[1]),
        .o_data (o_data)
    );

endmodule