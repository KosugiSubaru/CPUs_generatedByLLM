module alu_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,      // i_b[3:0] をシフト量として使用
    input  wire [3:0]  i_alu_op, // 0110:SRA, 0111:SLA
    output wire [15:0] o_result
);

    // バレルシフタを段階的なマルチプレクサ構造で実現する
    // 論理合成後の回路図で、各ステージ（1, 2, 4, 8ビット）のシフトの様子を視覚化する

    wire [15:0] w_r_stg1, w_r_stg2, w_r_stg3, w_r_stg4;
    wire [15:0] w_l_stg1, w_l_stg2, w_l_stg3, w_l_stg4;
    wire        w_sign;

    assign w_sign = i_a[15];

    // ---- 算術右シフト (SRA) パス ----
    // ステージ 1: 1ビットシフト
    assign w_r_stg1 = i_b[0] ? {w_sign, i_a[15:1]} : i_a;
    // ステージ 2: 2ビットシフト
    assign w_r_stg2 = i_b[1] ? {{2{w_sign}}, w_r_stg1[15:2]} : w_r_stg1;
    // ステージ 3: 4ビットシフト
    assign w_r_stg3 = i_b[2] ? {{4{w_sign}}, w_r_stg2[15:4]} : w_r_stg2;
    // ステージ 4: 8ビットシフト
    assign w_r_stg4 = i_b[3] ? {{8{w_sign}}, w_r_stg3[15:8]} : w_r_stg3;

    // ---- 算術左シフト (SLA) パス ----
    // ステージ 1: 1ビットシフト
    assign w_l_stg1 = i_b[0] ? {i_a[14:0], 1'b0} : i_a;
    // ステージ 2: 2ビットシフト
    assign w_l_stg2 = i_b[1] ? {w_l_stg1[13:0], 2'b0} : w_l_stg1;
    // ステージ 3: 4ビットシフト
    assign w_l_stg3 = i_b[2] ? {w_l_stg2[11:0], 4'b0} : w_l_stg2;
    // ステージ 4: 8ビットシフト
    assign w_l_stg4 = i_b[3] ? {w_l_stg3[7:0], 8'b0} : w_l_stg3;

    // 最終結果の選択
    assign o_result = (i_alu_op == 4'b0111) ? w_l_stg4 : w_r_stg4;

endmodule