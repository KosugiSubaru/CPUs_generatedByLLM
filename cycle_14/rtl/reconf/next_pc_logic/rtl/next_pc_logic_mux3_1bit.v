module next_pc_logic_mux3_1bit (
    input  wire [1:0] i_sel,    // 00: d0, 01: d1, 10: d2
    input  wire       i_d0,     // PC+2 のビット
    input  wire       i_d1,     // PC+imm のビット
    input  wire       i_d2,     // rs1+imm のビット
    output wire       o_q
);

    // 3入力1出力のセレクタ論理
    // 論理合成後の回路図で、次PC選択の最小単位として視覚化される
    assign o_q = (i_sel == 2'b00) ? i_d0 :
                 (i_sel == 2'b01) ? i_d1 :
                 (i_sel == 2'b10) ? i_d2 : 1'b0;

endmodule