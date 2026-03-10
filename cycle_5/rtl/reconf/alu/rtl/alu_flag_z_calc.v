module alu_flag_z_calc (
    input  wire [15:0] i_res,
    output wire        o_z
);

    // 16ビットの演算結果が全て0であるか判定する
    // ISA定義の behavior: "rd==0" に直接対応する回路
    // 論理合成において、全ビットの入力を受ける16入力NORゲート、または比較器として視覚化される
    assign o_z = (i_res == 16'h0000);

endmodule