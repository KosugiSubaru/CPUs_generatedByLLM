module imm_gen_ext8 (
    input  wire [7:0]  i_imm,
    output wire [15:0] o_imm
);

    // 8ビットの入力を16ビットへ符号拡張（ビット7を上位8ビットへコピー）
    assign o_imm = {{8{i_imm[7]}}, i_imm};

endmodule