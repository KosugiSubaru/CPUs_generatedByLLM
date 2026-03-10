module imm_gen_ext12 (
    input  wire [11:0] i_imm,
    output wire [15:0] o_imm
);

    // 12ビットの入力を16ビットへ符号拡張（ビット11を上位4ビットへコピー）
    assign o_imm = {{4{i_imm[11]}}, i_imm};

endmodule