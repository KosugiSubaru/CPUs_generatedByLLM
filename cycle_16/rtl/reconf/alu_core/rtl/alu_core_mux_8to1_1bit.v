module alu_core_mux_8to1_1bit (
    input  wire [2:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    input  wire       i_d4,
    input  wire       i_d5,
    input  wire       i_d6,
    input  wire       i_d7,
    output wire       o_q
);

    // 8つの1ビット入力から3ビットの選択信号に基づき1つを出力
    // 論理合成において標準的なマルチプレクサ回路として構成される
    assign o_q = (i_sel == 3'b000) ? i_d0 :
                 (i_sel == 3'b001) ? i_d1 :
                 (i_sel == 3'b010) ? i_d2 :
                 (i_sel == 3'b011) ? i_d3 :
                 (i_sel == 3'b100) ? i_d4 :
                 (i_sel == 3'b101) ? i_d5 :
                 (i_sel == 3'b110) ? i_d6 : i_d7;

endmodule