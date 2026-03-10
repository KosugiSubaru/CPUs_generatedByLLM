module register_file_mux_16to1_16bit (
    input  wire [3:0]   i_sel,
    input  wire [255:0] i_all_data,
    output wire [15:0]  o_out
);

    genvar j;
    genvar k;
    generate
        // 16ビットの各ビット（j）に対して、1ビット幅の16入力セレクタを配置
        for (j = 0; j < 16; j = j + 1) begin : gen_bit_slice
            wire [15:0] w_mux_in_bit_j;

            // 各レジスタ（k）のjビット目を集めて、16入力セレクタへの入力を作成
            for (k = 0; k < 16; k = k + 1) begin : gen_gather
                assign w_mux_in_bit_j[k] = i_all_data[k*16 + j];
            end

            register_file_mux_16to1_1bit u_mux_1bit (
                .i_sel (i_sel),
                .i_in  (w_mux_in_bit_j),
                .o_out (o_out[j])
            );
        end
    endgenerate

endmodule