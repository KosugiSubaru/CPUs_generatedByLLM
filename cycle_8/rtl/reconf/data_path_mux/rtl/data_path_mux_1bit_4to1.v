module data_path_mux_1bit_4to1 (
    input  wire [1:0] i_sel,
    input  wire       i_data0,
    input  wire       i_data1,
    input  wire       i_data2,
    input  wire       i_data3,
    output wire       o_q
);

    // 1ビット4対1セレクタの最小構成単位
    // 論理合成後の回路図において、複数のデータソース（ALU結果、メモリ、PC+2等）が
    // 1つのビットラインへ収束する物理的な地点を視覚化するために定義
    assign o_q = (i_sel == 2'b00) ? i_data0 :
                 (i_sel == 2'b01) ? i_data1 :
                 (i_sel == 2'b10) ? i_data2 : i_data3;

endmodule