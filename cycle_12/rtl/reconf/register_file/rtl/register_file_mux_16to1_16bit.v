module register_file_mux_16to1_16bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_d0,  i_d1,  i_d2,  i_d3,
    input  wire [15:0] i_d4,  i_d5,  i_d6,  i_d7,
    input  wire [15:0] i_d8,  i_d9,  i_d10, i_d11,
    input  wire [15:0] i_d12, i_d13, i_d14, i_d15,
    output wire [15:0] o_data
);

    // 16入力16ビットマルチプレクサを2to1マルチプレクサの木構造（ツリー）で構成する
    // 合成後の回路図でデータが二分木状に集約される構造を視覚化する

    wire [15:0] w_stg1 [7:0];
    wire [15:0] w_stg2 [3:0];
    wire [15:0] w_stg3 [1:0];

    // 各ステージの入力データをワイヤ配列にまとめる（generate文でのアクセスのため）
    wire [15:0] w_in [15:0];
    assign w_in[0]  = i_d0;  assign w_in[1]  = i_d1;  assign w_in[2]  = i_d2;  assign w_in[3]  = i_d3;
    assign w_in[4]  = i_d4;  assign w_in[5]  = i_d5;  assign w_in[6]  = i_d6;  assign w_in[7]  = i_d7;
    assign w_in[8]  = i_d8;  assign w_in[9]  = i_d9;  assign w_in[10] = i_d10; assign w_in[11] = i_d11;
    assign w_in[12] = i_d12; assign w_in[13] = i_d13; assign w_in[14] = i_d14; assign w_in[15] = i_d15;

    genvar i;
    generate
        // ステージ 1: 16入力 -> 8出力 (i_sel[0]を使用)
        for (i = 0; i < 8; i = i + 1) begin : gen_stg1
            register_file_mux_2to1_16bit u_mux1 (
                .i_sel  (i_sel[0]),
                .i_d0   (w_in[i*2]),
                .i_d1   (w_in[i*2+1]),
                .o_data (w_stg1[i])
            );
        end

        // ステージ 2: 8入力 -> 4出力 (i_sel[1]を使用)
        for (i = 0; i < 4; i = i + 1) begin : gen_stg2
            register_file_mux_2to1_16bit u_mux2 (
                .i_sel  (i_sel[1]),
                .i_d0   (w_stg1[i*2]),
                .i_d1   (w_stg1[i*2+1]),
                .o_data (w_stg2[i])
            );
        end

        // ステージ 3: 4入力 -> 2出力 (i_sel[2]を使用)
        for (i = 0; i < 2; i = i + 1) begin : gen_stg3
            register_file_mux_2to1_16bit u_mux3 (
                .i_sel  (i_sel[2]),
                .i_d0   (w_stg2[i*2]),
                .i_d1   (w_stg2[i*2+1]),
                .o_data (w_stg3[i])
            );
        end
    endgenerate

    // ステージ 4: 2入力 -> 1出力 (i_sel[3]を使用)
    register_file_mux_2to1_16bit u_mux_final (
        .i_sel  (i_sel[3]),
        .i_d0   (w_stg3[0]),
        .i_d1   (w_stg3[1]),
        .o_data (o_data)
    );

endmodule