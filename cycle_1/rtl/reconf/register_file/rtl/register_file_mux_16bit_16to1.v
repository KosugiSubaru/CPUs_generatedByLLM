module register_file_mux_16bit_16to1 (
    input  wire [3:0]   i_sel,
    input  wire [255:0] i_all_regs_data, // 16ビットx16個のレジスタデータをフラット化した入力
    output wire [15:0]  o_data
);

    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_per_bit
            wire [15:0] w_bit_collection;
            
            // 各レジスタの同じビット位置(i番目)を集める
            for (j = 0; j < 16; j = j + 1) begin : collect_bits
                assign w_bit_collection[j] = i_all_regs_data[j*16 + i];
            end

            // 1ビット単位の16to1セレクタをビット幅分インスタンス化
            register_file_mux_16to1_1bit u_mux_1bit (
                .i_sel  (i_sel),
                .i_data (w_bit_collection),
                .o_data (o_data[i])
            );
        end
    endgenerate

endmodule