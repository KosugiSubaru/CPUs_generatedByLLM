module alu_core_nbit_result_mux (
    input  wire [3:0]  i_sel,     // オペコード [3:0]
    input  wire [15:0] i_arith,   // 加減算パスの結果
    input  wire [15:0] i_logic,   // 論理演算パスの結果
    input  wire [15:0] i_shift,   // シフト演算パスの結果
    input  wire [15:0] i_imm,     // 即値直接ロード(loadi)パスの結果
    output wire [15:0] o_q        // 最終的なALU結果
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_result_mux_array
            // 1ビット結果選択セレクタのインスタンス化
            // 論理合成後の回路図において、16ビット並列に演算結果が絞り込まれる
            // 「データパスの収束」を視覚化するために定義
            alu_core_1bit_result_mux u_alu_core_1bit_result_mux (
                .i_sel   (i_sel),
                .i_arith (i_arith[i]),
                .i_logic (i_logic[i]),
                .i_shift (i_shift[i]),
                .i_imm   (i_imm[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule