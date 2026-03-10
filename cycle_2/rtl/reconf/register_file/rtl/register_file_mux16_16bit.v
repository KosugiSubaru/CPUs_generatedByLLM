module register_file_mux16_16bit (
    input  wire [255:0] i_data_bus, // 16ビット×16本 = 256ビット
    input  wire [3:0]   i_sel,      // 4ビット選択信号
    output wire [15:0]  o_data
);

    // 1段目の選択結果を保持するワイヤ (16ビット×4本 = 64ビット)
    wire [63:0] w_stage1_out;

    genvar i;

    // --- 1段目 (Layer 1) ---
    // 16個の入力を4つのグループに分け、下位2ビットで各グループから1つ選択
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_mux_stage1
            register_file_mux4_16bit u_mux4_stage1 (
                .i_sel (i_sel[1:0]),
                .i_d0  (i_data_bus[(i*4 + 0)*16 +: 16]),
                .i_d1  (i_data_bus[(i*4 + 1)*16 +: 16]),
                .i_d2  (i_data_bus[(i*4 + 2)*16 +: 16]),
                .i_d3  (i_data_bus[(i*4 + 3)*16 +: 16]),
                .o_y   (w_stage1_out[i*16 +: 16])
            );
        end
    endgenerate

    // --- 2段目 (Layer 2) ---
    // 1段目の4つの結果から、上位2ビットで最終的な1つを選択
    register_file_mux4_16bit u_mux4_stage2 (
        .i_sel (i_sel[3:2]),
        .i_d0  (w_stage1_out[0*16 +: 16]),
        .i_d1  (w_stage1_out[1*16 +: 16]),
        .i_d2  (w_stage1_out[2*16 +: 16]),
        .i_d3  (w_stage1_out[3*16 +: 16]),
        .o_y   (o_data)
    );

endmodule