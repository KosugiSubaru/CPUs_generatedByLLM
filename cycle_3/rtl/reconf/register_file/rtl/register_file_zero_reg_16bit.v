module register_file_zero_reg_16bit (
    output wire [15:0] o_q
);

    // ゼロレジスタ (R0) の実装
    // 内部にフリップフロップを持たず、常に定数0を出力する
    // 回路図上で、R1-R15の記憶素子ブロックとは異なる「定数源」として視覚化される
    assign o_q = 16'h0000;

endmodule