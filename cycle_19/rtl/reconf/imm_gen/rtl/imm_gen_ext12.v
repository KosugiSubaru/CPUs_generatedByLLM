module imm_gen_ext12 (
    input  wire [11:0] i_data, // 12ビットの即値入力
    output wire [15:0] o_data  // 16ビット符号拡張出力
);

    // 最上位ビット（i_data[11]）をコピーして16ビットに拡張
    assign o_data = {{4{i_data[11]}}, i_data};

endmodule