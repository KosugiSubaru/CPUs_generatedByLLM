module register_file_read_mux_16to1 (
    input  wire [3:0]   i_sel,     // アドレス (4ビット)
    input  wire [255:0] i_regs,    // 全16レジスタのフラット入力 (16bit * 16)
    output wire [15:0]  o_data     // 選択されたデータ
);

    // 階層的なMUX構造（2進ツリー）のための中間ワイヤ
    wire [15:0] w_stage1 [7:0];
    wire [15:0] w_stage2 [3:0];
    wire [15:0] w_stage3 [1:0];

    genvar i;

    // ステージ1: 16個のレジスタ入力から8個を選択 (addr[0]を使用)
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_mux_s1
            register_file_mux_2to1_16bit u_mux_s1 (
                .i_sel  (i_sel[0]),
                .i_d0   (i_regs[ (i*2)   * 16 +: 16]),
                .i_d1   (i_regs[ (i*2+1) * 16 +: 16]),
                .o_data (w_stage1[i])
            );
        end
    endgenerate

    // ステージ2: 8個の信号から4個を選択 (addr[1]を使用)
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_mux_s2
            register_file_mux_2to1_16bit u_mux_s2 (
                .i_sel  (i_sel[1]),
                .i_d0   (w_stage1[i*2]),
                .i_d1   (w_stage1[i*2+1]),
                .o_data (w_stage2[i])
            );
        end
    endgenerate

    // ステージ3: 4個の信号から2個を選択 (addr[2]を使用)
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_mux_s3
            register_file_mux_2to1_16bit u_mux_s3 (
                .i_sel  (i_sel[2]),
                .i_d0   (w_stage2[i*2]),
                .i_d1   (w_stage2[i*2+1]),
                .o_data (w_stage3[i])
            );
        end
    endgenerate

    // ステージ4: 最終選択 (addr[3]を使用)
    register_file_mux_2to1_16bit u_mux_s4 (
        .i_sel  (i_sel[3]),
        .i_d0   (w_stage3[0]),
        .i_d1   (w_stage3[1]),
        .o_data (o_data)
    );

endmodule