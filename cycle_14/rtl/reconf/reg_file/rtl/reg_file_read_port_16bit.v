module reg_file_read_port_16bit (
    input  wire [3:0]   i_addr,   // 読出アドレス (4bit)
    input  wire [255:0] i_rd_all, // 全16レジスタのフラット化データ (16*16bit)
    output wire [15:0]  o_data    // 選択されたレジスタデータ (16bit)
);

    genvar b; // ビット位置のインデックス (0-15)
    genvar r; // レジスタ番号のインデックス (0-15)

    generate
        for (b = 0; b < 16; b = b + 1) begin : gen_bit_slices
            // 16個のレジスタそれぞれの「b番目のビット」を束ねるための一時的な線
            wire [15:0] w_bits_from_regs;

            for (r = 0; r < 16; r = r + 1) begin : gather_bits
                assign w_bits_from_regs[r] = i_rd_all[r*16 + b];
            end

            // 各ビットごとに16入力1出力のセレクタを配置（パタン構造化）
            reg_file_mux_16to1_1bit u_mux_1bit (
                .i_sel  (i_addr),
                .i_in   (w_bits_from_regs),
                .o_out  (o_data[b])
            );
        end
    endgenerate

endmodule