module alu_core_1bit_result_mux (
    input  wire [3:0] i_sel,   // オペコード [3:0]
    input  wire       i_arith, // 算術演算結果の1ビット
    input  wire       i_logic, // 論理演算結果の1ビット
    input  wire       i_shift, // シフト演算結果の1ビット
    input  wire       i_imm,   // 即値ロード結果の1ビット
    output wire       o_q      // 選択された1ビット結果
);

    // ISAのオペコードに基づき、どの演算ユニットの出力を採用するかを選択
    // 論理合成後の回路図で、演算パスが収束する様子を視覚化するための最小単位
    assign o_q = (i_sel == 4'b0000) ? i_arith : // add
                 (i_sel == 4'b0001) ? i_arith : // sub
                 (i_sel == 4'b0010) ? i_logic : // and
                 (i_sel == 4'b0011) ? i_logic : // or
                 (i_sel == 4'b0100) ? i_logic : // xor
                 (i_sel == 4'b0101) ? i_logic : // not
                 (i_sel == 4'b0110) ? i_shift : // sra
                 (i_sel == 4'b0111) ? i_shift : // sla
                 (i_sel == 4'b1000) ? i_arith : // addi
                 (i_sel == 4'b1001) ? i_imm   : // loadi
                 (i_sel == 4'b1010) ? i_arith : // load (addr calculation)
                 (i_sel == 4'b1011) ? i_arith : // store (addr calculation)
                 1'b0;

endmodule