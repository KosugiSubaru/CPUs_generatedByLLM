module register_file_mux16 (
    input  wire [255:0] i_reg_bus,
    input  wire [3:0]   i_sel,
    output wire [15:0]  o_data
);

    wire [15:0] w_mux_l1_out [3:0];
    genvar i;

    // 1段目: 16個の入力を4つのグループに分け、下位2ビットでそれぞれ選択
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_l1_mux
            register_file_mux4 u_mux4_l1 (
                .i_data0 (i_reg_bus[(i*4+0)*16 +: 16]),
                .i_data1 (i_reg_bus[(i*4+1)*16 +: 16]),
                .i_data2 (i_reg_bus[(i*4+2)*16 +: 16]),
                .i_data3 (i_reg_bus[(i*4+3)*16 +: 16]),
                .i_sel   (i_sel[1:0]),
                .o_data  (w_mux_l1_out[i])
            );
        end
    endgenerate

    // 2段目: 1段目の4つの出力から、上位2ビットで最終的な1つを選択
    register_file_mux4 u_mux4_l2 (
        .i_data0 (w_mux_l1_out[0]),
        .i_data1 (w_mux_l1_out[1]),
        .i_data2 (w_mux_l1_out[2]),
        .i_data3 (w_mux_l1_out[3]),
        .i_sel   (i_sel[3:2]),
        .o_data  (o_data)
    );

endmodule