module register_file_read_mux (
    input  wire [3:0]   i_sel,
    input  wire [255:0] i_regs,
    output wire [15:0]  o_data
);

    genvar i, j;
    generate
        // 16ビットのデータ幅分、1ビットセレクタを並列に配置
        for (i = 0; i < 16; i = i + 1) begin : gen_bit_mux
            // 全レジスタ(16個)からi番目のビットだけを集めた配線
            wire [15:0] w_bit_pool;
            for (j = 0; j < 16; j = j + 1) begin : gen_bit_collect
                assign w_bit_pool[j] = i_regs[j*16 + i];
            end

            // 1ビット16入力セレクタのインスタンス化
            register_file_1bit_mux_16to1 u_mux_1bit (
                .i_sel  (i_sel),
                .i_data (w_bit_pool),
                .o_q    (o_data[i])
            );
        end
    endgenerate

endmodule