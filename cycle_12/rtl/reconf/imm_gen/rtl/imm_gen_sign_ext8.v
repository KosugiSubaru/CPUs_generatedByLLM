module imm_gen_sign_ext8 (
    input  wire [7:0]  i_imm_8bit,
    output wire [15:0] o_imm_16bit
);

    // 下位8ビットをそのまま出力し、上位ビットを入力の符号ビット(bit 7)で埋める
    // 論理合成後の回路図で、符号ビットが複数の上位ビットへ分岐して接続される構造を視覚化する
    assign o_imm_16bit[7:0]   = i_imm_8bit[7:0];
    assign o_imm_16bit[15:8]  = {8{i_imm_8bit[7]}};

endmodule