module writeback_mux_4to1_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_q
);

    genvar i;

    // 16ビット幅のデータパスを選択回路ごとにビット分割して構造化
    // 各ビットに対して1ビット幅のマルチプレクサを並列に配置する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_bits
            writeback_mux_4to1_1bit u_mux_bit (
                .i_sel (i_sel),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .i_d2  (i_d2[i]),
                .i_d3  (i_d3[i]),
                .o_q   (o_q[i])
            );
        end
    endgenerate

endmodule