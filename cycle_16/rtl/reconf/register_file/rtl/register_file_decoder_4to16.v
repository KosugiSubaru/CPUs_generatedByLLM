module register_file_decoder_4to16 (
    input  wire [3:0]  i_addr,
    output wire [15:0] o_dec
);

    // 4ビットのアドレス入力を16本のOne-hot信号に変換
    // 各ビットの代入文が論理合成後に並列なデコード回路として視覚化される
    assign o_dec[0]  = (i_addr == 4'd0);
    assign o_dec[1]  = (i_addr == 4'd1);
    assign o_dec[2]  = (i_addr == 4'd2);
    assign o_dec[3]  = (i_addr == 4'd3);
    assign o_dec[4]  = (i_addr == 4'd4);
    assign o_dec[5]  = (i_addr == 4'd5);
    assign o_dec[6]  = (i_addr == 4'd6);
    assign o_dec[7]  = (i_addr == 4'd7);
    assign o_dec[8]  = (i_addr == 4'd8);
    assign o_dec[9]  = (i_addr == 4'd9);
    assign o_dec[10] = (i_addr == 4'd10);
    assign o_dec[11] = (i_addr == 4'd11);
    assign o_dec[12] = (i_addr == 4'd12);
    assign o_dec[13] = (i_addr == 4'd13);
    assign o_dec[14] = (i_addr == 4'd14);
    assign o_dec[15] = (i_addr == 4'd15);

endmodule