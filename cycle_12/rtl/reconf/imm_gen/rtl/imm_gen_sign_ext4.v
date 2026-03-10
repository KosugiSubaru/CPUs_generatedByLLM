module imm_gen_sign_ext4 (
    input  wire [3:0]  i_imm_4bit,
    output wire [15:0] o_imm_16bit
);

    // 下位4ビットをそのまま出力し、上位ビットを入力の符号ビット(bit 3)で埋める
    // 論理合成後の回路図で、符号ビットが複数の上位ビットへ分岐して接続される構造を視覚化する
    assign o_imm_16bit[3:0]  = i_imm_4bit[3:0];
    assign o_imm_16bit[15:4] = {12{i_imm_4bit[3]}};

endmodule