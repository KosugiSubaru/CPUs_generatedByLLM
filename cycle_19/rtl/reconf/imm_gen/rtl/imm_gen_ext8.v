module imm_gen_ext8 (
    input  wire [7:0]  i_data, // 8ビットの即値入力
    output wire [15:0] o_data  // 16ビット符号拡張出力
);

    // 最上位ビット（i_data[7]）をコピーして16ビットに拡張
    assign o_data = {{8{i_data[7]}}, i_data};

endmodule