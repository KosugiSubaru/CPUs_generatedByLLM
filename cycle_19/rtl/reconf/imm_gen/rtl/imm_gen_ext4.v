module imm_gen_ext4 (
    input  wire [3:0]  i_data, // 4ビットの即値入力
    output wire [15:0] o_data  // 16ビット符号拡張出力
);

    // 最上位ビット（i_data[3]）をコピーして16ビットに拡張
    assign o_data = {{12{i_data[3]}}, i_data};

endmodule