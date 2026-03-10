module register_file_mux16_16bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_data0,  input  wire [15:0] i_data1,
    input  wire [15:0] i_data2,  input  wire [15:0] i_data3,
    input  wire [15:0] i_data4,  input  wire [15:0] i_data5,
    input  wire [15:0] i_data6,  input  wire [15:0] i_data7,
    input  wire [15:0] i_data8,  input  wire [15:0] i_data9,
    input  wire [15:0] i_data10, input  wire [15:0] i_data11,
    input  wire [15:0] i_data12, input  wire [15:0] i_data13,
    input  wire [15:0] i_data14, input  wire [15:0] i_data15,
    output wire [15:0] o_data
);

    genvar j;

    // 各ビット（0〜15）に対して、16個のレジスタから1つを選ぶ1bit-MUXを16個配置する
    generate
        for (j = 0; j < 16; j = j + 1) begin : gen_mux16_bits
            wire [15:0] w_bit_slice;

            // 各レジスタのj番目のビットを集めて、1bit-16入力MUXへの入力とする
            assign w_bit_slice = {
                i_data15[j], i_data14[j], i_data13[j], i_data12[j],
                i_data11[j], i_data10[j], i_data9[j], i_data8[j],
                i_data7[j],  i_data6[j],  i_data5[j],  i_data4[j],
                i_data3[j],  i_data2[j],  i_data1[j],  i_data0[j]
            };

            register_file_mux16_1bit u_mux1bit (
                .i_sel  (i_sel),
                .i_data (w_bit_slice),
                .o_data (o_data[j])
            );
        end
    endgenerate

endmodule