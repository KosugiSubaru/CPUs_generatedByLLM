module register_file_mux_4to1 (
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    input  wire [1:0]  i_sel,
    output wire [15:0] o_data
);

    // 4つの16ビット入力から、2ビットの選択信号に基づいて1つを出力する
    // 論理合成において、この条件演算子はセレクタ回路として視覚化される
    assign o_data = (i_sel == 2'b00) ? i_d0 :
                    (i_sel == 2'b01) ? i_d1 :
                    (i_sel == 2'b10) ? i_d2 :
                                       i_d3;

endmodule