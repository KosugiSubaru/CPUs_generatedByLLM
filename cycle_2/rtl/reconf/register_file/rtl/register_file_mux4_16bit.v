module register_file_mux4_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_y
);

    genvar i;

    // 16ビットの各ビットに対して4入力セレクタの論理を生成
    // 論理合成後の回路図で、16個のセレクタが並列に並ぶ構造を視覚化する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_bits
            assign o_y[i] = (i_sel == 2'b00) ? i_d0[i] :
                            (i_sel == 2'b01) ? i_d1[i] :
                            (i_sel == 2'b10) ? i_d2[i] : i_d3[i];
        end
    endgenerate

endmodule