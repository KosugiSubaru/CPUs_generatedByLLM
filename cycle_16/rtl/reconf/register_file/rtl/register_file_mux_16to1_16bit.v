module register_file_mux_16to1_16bit (
    input  wire [3:0]   i_sel,
    input  wire [255:0] i_data_bus, // 16bit * 16レジスタの連結データ
    output wire [15:0]  o_data
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bit_mux
            // 各レジスタのi番目のビットを抽出して16入力MUXに渡すためのワイヤ
            wire [15:0] w_mux_input = {
                i_data_bus[15*16 + i], i_data_bus[14*16 + i], i_data_bus[13*16 + i], i_data_bus[12*16 + i],
                i_data_bus[11*16 + i], i_data_bus[10*16 + i], i_data_bus[9*16 + i],  i_data_bus[8*16 + i],
                i_data_bus[7*16 + i],  i_data_bus[6*16 + i],  i_data_bus[5*16 + i],  i_data_bus[4*16 + i],
                i_data_bus[3*16 + i],  i_data_bus[2*16 + i],  i_data_bus[1*16 + i],  i_data_bus[0*16 + i]
            };

            // 1ビット幅の16入力MUXをインスタンス化（パタン構造化）
            register_file_mux_16to1_1bit u_mux_1bit (
                .i_sel  (i_sel),
                .i_data (w_mux_input),
                .o_q    (o_data[i])
            );
        end
    endgenerate

endmodule