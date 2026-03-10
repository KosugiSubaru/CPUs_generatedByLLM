module imm_gen_ext12 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire [11:0] w_raw_imm;

    // B形式(blt, bz)の即値フィールド[15:4]を抽出
    assign w_raw_imm = i_instr[15:4];

    // 12ビット入力を16ビットへ符号拡張するパタン構造化
    generate
        imm_gen_sign_ext #(
            .IN_WIDTH(12)
        ) u_sign_ext (
            .i_in  (w_raw_imm),
            .o_out (o_imm)
        );
    endgenerate

endmodule