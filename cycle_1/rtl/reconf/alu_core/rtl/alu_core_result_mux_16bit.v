module alu_core_result_mux_16bit (
    input  wire [2:0]  i_sel,
    input  wire [15:0] i_d0, // Add/Sub
    input  wire [15:0] i_d1, // Sub (未使用、d0と統合)
    input  wire [15:0] i_d2, // And
    input  wire [15:0] i_d3, // Or
    input  wire [15:0] i_d4, // Xor
    input  wire [15:0] i_d5, // Not
    input  wire [15:0] i_d6, // SRA
    input  wire [15:0] i_d7, // SLA
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_result_mux
            // 8入力1ビットセレクタを16ビット分並列化
            // 回路図上で、各ビットの結果がopcodeの下位3ビットで選ばれる様子を視覚化
            alu_core_mux_8to1_1bit u_mux (
                .i_sel  (i_sel),
                .i_d0   (i_d0[i]),
                .i_d1   (i_d0[i]), // 加算と減算はadder_subモジュール内で完結
                .i_d2   (i_d2[i]),
                .i_d3   (i_d3[i]),
                .i_d4   (i_d4[i]),
                .i_d5   (i_d5[i]),
                .i_d6   (i_d6[i]),
                .i_d7   (i_d7[i]),
                .o_data (o_data[i])
            );
        end
    endgenerate

endmodule