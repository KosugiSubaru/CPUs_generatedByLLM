module data_path_mux_nbit_alu_src (
    input  wire        i_sel,   // 0: rs2_data, 1: imm_data
    input  wire [15:0] i_data0, // rs2_data
    input  wire [15:0] i_data1, // imm_data
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_alu_src_mux_array
            // 1ビット2対1セレクタのインスタンス化
            // 論理合成後の回路図において、16ビット並列にデータが切り替わる
            // ビット並列構造を視覚化するために定義
            data_path_mux_1bit_2to1 u_data_path_mux_1bit_2to1 (
                .i_sel   (i_sel),
                .i_data0 (i_data0[i]),
                .i_data1 (i_data1[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule