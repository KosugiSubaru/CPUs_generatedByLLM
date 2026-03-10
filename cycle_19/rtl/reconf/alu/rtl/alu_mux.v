module alu_mux (
    input  wire [3:0]  i_alu_op,    // ALU演算種別信号
    input  wire [15:0] i_arith_res, // 算術演算ユニットの結果
    input  wire [15:0] i_logic_res, // 論理演算ユニットの結果
    input  wire [15:0] i_shift_res, // シフト演算ユニットの結果
    input  wire [15:0] i_imm,       // 即値データ（loadi用）
    output wire [15:0] o_res        // 最終的な演算結果
);

    // オペコードに応じて各演算ユニットの出力から1つを選択
    // Arith(加減算系): 0000, 0001, 1000, 1010, 1011, 1111
    // Logic(論理演算): 0010, 0011, 0100, 0101
    // Shift(シフト):   0110, 0111
    // Imm(即値ロード): 1001
    assign o_res = (i_alu_op == 4'b0000 || i_alu_op == 4'b0001 || i_alu_op == 4'b1000 || 
                    i_alu_op == 4'b1010 || i_alu_op == 4'b1011 || i_alu_op == 4'b1111) ? i_arith_res :
                   (i_alu_op == 4'b0010 || i_alu_op == 4'b0011 || i_alu_op == 4'b0100 || 
                    i_alu_op == 4'b0101)                                               ? i_logic_res :
                   (i_alu_op == 4'b0110 || i_alu_op == 4'b0111)                        ? i_shift_res :
                   (i_alu_op == 4'b1001)                                               ? i_imm       :
                   16'h0000;

endmodule