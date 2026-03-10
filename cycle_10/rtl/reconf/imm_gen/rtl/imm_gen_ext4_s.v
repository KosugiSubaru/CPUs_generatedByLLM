module imm_gen_ext4_s (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire [3:0] w_raw_imm;

    // S形式(store)の即値フィールド[15:12]を抽出
    assign w_raw_imm = i_instr[15:12];

    // 4ビット入力を16ビットへ符号拡張するパタン構造化
    generate
        imm_gen_sign_ext #(
            .IN_WIDTH(4)
        ) u_sign_ext (
            .i_in  (w_raw_imm),
            .o_out (o_imm)
        );
    endgenerate

endmodule