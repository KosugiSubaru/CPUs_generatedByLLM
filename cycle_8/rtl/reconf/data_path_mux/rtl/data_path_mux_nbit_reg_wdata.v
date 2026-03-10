module data_path_mux_nbit_reg_wdata (
    input  wire [1:0]  i_sel,   // 00:ALU, 01:Mem, 10:PC+2, 11:Reserved
    input  wire [15:0] i_data0, // ALU結果
    input  wire [15:0] i_data1, // メモリデータ
    input  wire [15:0] i_data2, // PC+2
    input  wire [15:0] i_data3, // 予備
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_reg_wdata_mux_array
            // 1ビット4対1セレクタのインスタンス化
            // 論理合成後の回路図において、16ビット並列にデータソースが切り替わる
            // 演算結果、メモリ、戻りアドレスの「合流地点」を視覚化するために定義
            data_path_mux_1bit_4to1 u_data_path_mux_1bit_4to1 (
                .i_sel   (i_sel),
                .i_data0 (i_data0[i]),
                .i_data1 (i_data1[i]),
                .i_data2 (i_data2[i]),
                .i_data3 (i_data3[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule