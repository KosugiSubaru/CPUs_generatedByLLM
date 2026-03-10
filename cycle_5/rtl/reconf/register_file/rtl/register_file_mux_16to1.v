module register_file_mux_16to1 (
    input  wire [255:0] i_all_data, // 16ビット×16レジスタのフラット化入力
    input  wire [3:0]   i_sel,      // 4ビット選択信号
    output wire [15:0]  o_data      // 選択された16ビット出力
);

    wire [63:0] w_stage1_out;
    genvar i;

    // 第1段階: 4入力MUXを4個並列に配置 (下位2ビット i_sel[1:0] で選択)
    // 16個の入力を4個の候補に絞り込むパターン構造
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_mux_stage1
            register_file_mux_4to1 u_mux_stage1 (
                .i_d0   (i_all_data[(i*4+0)*16 +: 16]),
                .i_d1   (i_all_data[(i*4+1)*16 +: 16]),
                .i_d2   (i_all_data[(i*4+2)*16 +: 16]),
                .i_d3   (i_all_data[(i*4+3)*16 +: 16]),
                .i_sel  (i_sel[1:0]),
                .o_data (w_stage1_out[i*16 +: 16])
            );
        end
    endgenerate

    // 第2段階: 4入力MUXを1個配置 (上位2ビット i_sel[3:2] で選択)
    // 第1段階の出力から最終的な1つを選択
    register_file_mux_4to1 u_mux_stage2 (
        .i_d0   (w_stage1_out[0*16 +: 16]),
        .i_d1   (w_stage1_out[1*16 +: 16]),
        .i_d2   (w_stage1_out[2*16 +: 16]),
        .i_d3   (w_stage1_out[3*16 +: 16]),
        .i_sel  (i_sel[3:2]),
        .o_data (o_data)
    );

endmodule