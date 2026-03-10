module imm_gen_bit_ext (
    input  wire i_inst_bit,
    input  wire i_sign_bit,
    input  wire i_is_ext_zone,
    output wire o_bit
);

    // データ有効範囲（i_is_ext_zone=0）なら命令ビットを、
    // 拡張範囲（i_is_ext_zone=1）なら符号ビットを出力する
    assign o_bit = i_is_ext_zone ? i_sign_bit : i_inst_bit;

endmodule