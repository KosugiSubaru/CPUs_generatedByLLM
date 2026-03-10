module imm_gen_ext8 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire [7:0] w_raw_imm;

    // L形式(loadi, jal)の即値フィールド[11:4]を抽出
    assign w_raw_imm = i_instr[11:4];

    // 8ビット入力を16ビットへ符号拡張するパタン構造化
    generate
        imm_gen_sign_ext #(
            .IN_WIDTH(8)
        ) u_sign_ext (
            .i_in  (w_raw_imm),
            .o_out (o_imm)
        );
    endgenerate

endmodule