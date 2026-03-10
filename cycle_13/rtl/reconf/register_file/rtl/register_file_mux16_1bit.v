module register_file_mux16_1bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_data,
    output wire        o_data
);

    wire [7:0] w_l1;
    wire [3:0] w_l2;
    wire [1:0] w_l3;

    genvar i;

    // 2入力MUXを階層的に組み合わせることで、16入力MUXをツリー構造で構成する
    generate
        // 第1層: 16入力 -> 8出力
        for (i = 0; i < 8; i = i + 1) begin : gen_l1
            register_file_mux2_1bit u_mux_l1 (
                .i_sel  (i_sel[0]),
                .i_d0   (i_data[i*2]),
                .i_d1   (i_data[i*2+1]),
                .o_data (w_l1[i])
            );
        end

        // 第2層: 8入力 -> 4出力
        for (i = 0; i < 4; i = i + 1) begin : gen_l2
            register_file_mux2_1bit u_mux_l2 (
                .i_sel  (i_sel[1]),
                .i_d0   (w_l1[i*2]),
                .i_d1   (w_l1[i*2+1]),
                .o_data (w_l2[i])
            );
        end

        // 第3層: 4入力 -> 2出力
        for (i = 0; i < 2; i = i + 1) begin : gen_l3
            register_file_mux2_1bit u_mux_l3 (
                .i_sel  (i_sel[2]),
                .i_d0   (w_l2[i*2]),
                .i_d1   (w_l2[i*2+1]),
                .o_data (w_l3[i])
            );
        end
    endgenerate

    // 第4層: 2入力 -> 1出力（最終結果）
    register_file_mux2_1bit u_mux_l4 (
        .i_sel  (i_sel[3]),
        .i_d0   (w_l3[0]),
        .i_d1   (w_l3[1]),
        .o_data (o_data)
    );

endmodule