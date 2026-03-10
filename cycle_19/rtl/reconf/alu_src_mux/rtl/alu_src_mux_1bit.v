module alu_src_mux_1bit (
    input  wire i_sel,  // 選択信号 (0: rs2_data, 1: imm_data)
    input  wire i_rs2,  // レジスタファイル入力 (1ビット)
    input  wire i_imm,  // 即値ジェネレータ入力 (1ビット)
    output wire o_data  // 選択出力
);

    // 2入力1出力マルチプレクサの基本論理
    assign o_data = (i_sel) ? i_imm : i_rs2;

endmodule