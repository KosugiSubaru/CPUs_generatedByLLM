module write_back_mux (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_alu_res,
    input  wire [15:0] i_mem_data,
    input  wire [15:0] i_pc_plus_2,
    input  wire [15:0] i_imm_data,
    output wire [15:0] o_wb_data
);

    genvar i;

    // 4入力1ビットマルチプレクサを16個並列に配置し、レジスタ書き戻しパスを構造化する
    // i_sel[1:0] の値に応じて、以下のデータを選択して出力する
    // 00: ALU演算結果
    // 01: データメモリ読み出し値
    // 10: PC+2 (JAL/JALR用リンクアドレス)
    // 11: 符号拡張済み即値 (loadi用)
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_wb_mux_bits
            write_back_mux_4to1_1bit u_mux_4to1 (
                .i_sel  (i_sel),
                .i_d0   (i_alu_res[i]),
                .i_d1   (i_mem_data[i]),
                .i_d2   (i_pc_plus_2[i]),
                .i_d3   (i_imm_data[i]),
                .o_data (o_wb_data[i])
            );
        end
    endgenerate

endmodule