module imm_gen_ext4 (
    input  wire [3:0]  i_imm,
    output wire [15:0] o_imm
);

    // 4ビットの入力を16ビットへ符号拡張（ビット3を上位12ビットへコピー）
    assign o_imm = {{12{i_imm[3]}}, i_imm};

endmodule