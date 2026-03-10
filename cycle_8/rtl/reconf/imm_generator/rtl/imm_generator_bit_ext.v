module imm_generator_bit_ext (
    input  wire i_bit,
    output wire o_bit
);

    // 符号拡張回路における1ビットの最小単位を構成
    // 論理合成後の回路図において、ビットごとの配線や符号ビットのコピーを
    // 明示的な物理ブロックとして視覚化するために定義
    assign o_bit = i_bit;

endmodule