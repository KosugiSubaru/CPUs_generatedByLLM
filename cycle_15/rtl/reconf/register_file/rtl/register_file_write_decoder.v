module register_file_write_decoder (
    input  wire [3:0]  i_addr,
    input  wire        i_wen,
    output wire [15:0] o_wen
);

    // 書き込み先アドレス(rd)をデコードし、16本のレジスタのうち1本に対して書き込み有効信号を供給する
    // 明示的にビットごとに記述することで、論理合成後の回路図において
    // アドレス比較器とANDゲートによるデコード構造が視覚的に理解しやすくなる
    assign o_wen[0]  = i_wen & (i_addr == 4'd0);
    assign o_wen[1]  = i_wen & (i_addr == 4'd1);
    assign o_wen[2]  = i_wen & (i_addr == 4'd2);
    assign o_wen[3]  = i_wen & (i_addr == 4'd3);
    assign o_wen[4]  = i_wen & (i_addr == 4'd4);
    assign o_wen[5]  = i_wen & (i_addr == 4'd5);
    assign o_wen[6]  = i_wen & (i_addr == 4'd6);
    assign o_wen[7]  = i_wen & (i_addr == 4'd7);
    assign o_wen[8]  = i_wen & (i_addr == 4'd8);
    assign o_wen[9]  = i_wen & (i_addr == 4'd9);
    assign o_wen[10] = i_wen & (i_addr == 4'd10);
    assign o_wen[11] = i_wen & (i_addr == 4'd11);
    assign o_wen[12] = i_wen & (i_addr == 4'd12);
    assign o_wen[13] = i_wen & (i_addr == 4'd13);
    assign o_wen[14] = i_wen & (i_addr == 4'd14);
    assign o_wen[15] = i_wen & (i_addr == 4'd15);

endmodule