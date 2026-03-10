module immediate_generator_sign_ext_bit (
    input  wire i_raw_bit,
    input  wire i_sign_bit,
    input  wire i_use_sign,
    output wire o_ext_bit
);

    // i_use_signが1なら符号ビット(MSB)を、0なら命令から抽出した生ビットを出力
    assign o_ext_bit = (i_use_sign) ? i_sign_bit : i_raw_bit;

endmodule