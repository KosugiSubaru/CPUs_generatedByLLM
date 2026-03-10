module register_file_mux16to1_16bit (
    input  wire [3:0]   i_select,
    input  wire [255:0] i_data,
    output wire [15:0]  o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_mux_bits
            // 16個のレジスタからiビット目のみを集めて、1ビット16入力MUXに供給
            register_file_mux16to1_1bit u_mux_1bit (
                .i_select (i_select),
                .i_data   ({i_data[240+i], i_data[224+i], i_data[208+i], i_data[192+i],
                            i_data[176+i], i_data[160+i], i_data[144+i], i_data[128+i],
                            i_data[112+i], i_data[96+i],  i_data[80+i],  i_data[64+i],
                            i_data[48+i],  i_data[32+i],  i_data[16+i],  i_data[0+i]}),
                .o_data   (o_data[i])
            );
        end
    endgenerate

endmodule