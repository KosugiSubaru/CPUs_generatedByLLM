module register_file_mux_16to1_16bit (
    input  wire [3:0]   i_sel,
    input  wire [255:0] i_data, // 16ビットx16個のレジスタデータをフラット化した入力
    output wire [15:0]  o_y
);

    // 16個のレジスタデータから、アドレス(i_sel)に基づいて1つを選択
    // 論理合成においてMUX木として視覚化されるよう、条件演算子を列挙
    assign o_y = (i_sel == 4'h0) ? i_data[15:0]    :
                 (i_sel == 4'h1) ? i_data[31:16]   :
                 (i_sel == 4'h2) ? i_data[47:32]   :
                 (i_sel == 4'h3) ? i_data[63:48]   :
                 (i_sel == 4'h4) ? i_data[79:64]   :
                 (i_sel == 4'h5) ? i_data[95:80]   :
                 (i_sel == 4'h6) ? i_data[111:96]  :
                 (i_sel == 4'h7) ? i_data[127:112] :
                 (i_sel == 4'h8) ? i_data[143:128] :
                 (i_sel == 4'h9) ? i_data[159:144] :
                 (i_sel == 4'ha) ? i_data[175:160] :
                 (i_sel == 4'hb) ? i_data[191:176] :
                 (i_sel == 4'hc) ? i_data[207:192] :
                 (i_sel == 4'hd) ? i_data[223:208] :
                 (i_sel == 4'he) ? i_data[239:224] :
                                   i_data[255:240]; // 4'hf

endmodule