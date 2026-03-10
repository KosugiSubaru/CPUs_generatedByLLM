module alu_flag_logic (
    input  wire [3:0]  i_op,
    input  wire [15:0] i_src1,
    input  wire [15:0] i_src2,
    input  wire [15:0] i_result,
    output wire        o_z,
    output wire        o_n,
    output wire        o_v
);

    // Zero flag: 全ビットが0であることを判定
    assign o_z = (i_result == 16'h0000);

    // Negative flag: 結果のMSB（符号ビット）が1であることを判定
    assign o_n = i_result[15];

    // Overflow flag (V): 演算の種類によって計算式を切り替え
    wire w_v_add;
    wire w_v_sub;

    // 加算時のオーバーフロー: 正+正=負、または 負+負=正 となった場合
    // (addi, load, store, jal, jalr 等の加算処理も含む)
    assign w_v_add = (i_src1[15] == 1'b1 && i_src2[15] == 1'b1 && i_result[15] == 1'b0) ||
                     (i_src1[15] == 1'b0 && i_src2[15] == 1'b0 && i_result[15] == 1'b1);

    // 減算時のオーバーフロー: 正-負=負、または 負-正=正 となった場合
    assign w_v_sub = (i_src1[15] == 1'b0 && i_src2[15] == 1'b1 && i_result[15] == 1'b1) ||
                     (i_src1[15] == 1'b1 && i_src2[15] == 1'b0 && i_result[15] == 1'b0);

    // opcodeが subtraction (0001) の時のみ減算用ロジックを使用、それ以外は加算用
    assign o_v = (i_op == 4'b0001) ? w_v_sub : w_v_add;

endmodule