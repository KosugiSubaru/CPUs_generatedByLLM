module imm_gen_mux5_1bit (
    input  wire [2:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    input  wire       i_d4,
    output wire       o_q
);

    // 5つの入力ビットから、選択信号に基づいて1つを出力する
    // 論理合成後の回路図で、即値選択の最小単位として視覚化される
    assign o_q = (i_sel == 3'd0) ? i_d0 :
                 (i_sel == 3'd1) ? i_d1 :
                 (i_sel == 3'd2) ? i_d2 :
                 (i_sel == 3'd3) ? i_d3 :
                 (i_sel == 3'd4) ? i_d4 : 1'b0;

endmodule