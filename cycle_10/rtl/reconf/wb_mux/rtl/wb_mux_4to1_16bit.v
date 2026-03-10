module wb_mux_4to1_16bit (
    input  wire [15:0] i_data0,
    input  wire [15:0] i_data1,
    input  wire [15:0] i_data2,
    input  wire [15:0] i_data3,
    input  wire [1:0]  i_sel,
    output wire [15:0] o_data
);

    genvar i;

    // 16ビットの各ビットに対して1ビットマルチプレクサを並列に配置
    // 論理合成後の回路図で、16個の同じ構造のセレクタが並ぶ様子が視覚化される
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_bits
            wb_mux_bit_slice u_slice (
                .i_bit0 (i_data0[i]),
                .i_bit1 (i_data1[i]),
                .i_bit2 (i_data2[i]),
                .i_bit3 (i_data3[i]),
                .i_sel  (i_sel),
                .o_bit  (o_data[i])
            );
        end
    endgenerate

endmodule