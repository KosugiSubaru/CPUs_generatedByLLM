module next_pc_logic_mux_4to1_1bit (
    input  wire [1:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    output wire       o_q
);

    // 2ビットの選択信号に基づき、4つの1ビット入力から1つを出力
    // 論理合成において標準的なマルチプレクサ回路として構成される
    assign o_q = (i_sel == 2'b00) ? i_d0 :
                 (i_sel == 2'b01) ? i_d1 :
                 (i_sel == 2'b10) ? i_d2 : i_d3;

endmodule