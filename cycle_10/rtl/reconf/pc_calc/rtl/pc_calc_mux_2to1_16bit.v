module pc_calc_mux_2to1_16bit (
    input  wire [15:0] i_data0,
    input  wire [15:0] i_data1,
    input  wire        i_sel,
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_bits
            // 1ビットのセレクタが16ビット分並列に並んでいる様子を構造化
            // i_selが0ならi_data0を、1ならi_data1を選択
            assign o_data[i] = (i_sel) ? i_data1[i] : i_data0[i];
        end
    endgenerate

endmodule