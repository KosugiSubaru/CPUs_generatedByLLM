module writeback_mux_1bit (
    input  wire [1:0] i_sel, // 選択信号 (00:ALU, 01:Mem, 10:PC+2)
    input  wire       i_alu, // ALU演算結果（1ビット）
    input  wire       i_mem, // メモリ読み出しデータ（1ビット）
    input  wire       i_pc2, // リンクアドレス PC+2（1ビット）
    output wire       o_data // 選択出力
);

    // 3入力マルチプレクサの基本論理
    assign o_data = (i_sel == 2'b01) ? i_mem :
                    (i_sel == 2'b10) ? i_pc2 :
                                       i_alu;

endmodule