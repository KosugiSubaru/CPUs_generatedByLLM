module register_file_decoder_4to16 (
    input  wire [3:0]  i_addr,
    output wire [15:0] o_decode
);

    // 4ビットのアドレスを16本の独立した信号線に変換（1-of-16 デコード）
    // 10進数表記（4'd）を使用して、ビット幅と値の整合性を修正
    assign o_decode[0]  = (i_addr == 4'd0);
    assign o_decode[1]  = (i_addr == 4'd1);
    assign o_decode[2]  = (i_addr == 4'd2);
    assign o_decode[3]  = (i_addr == 4'd3);
    assign o_decode[4]  = (i_addr == 4'd4);
    assign o_decode[5]  = (i_addr == 4'd5);
    assign o_decode[6]  = (i_addr == 4'd6);
    assign o_decode[7]  = (i_addr == 4'd7);
    assign o_decode[8]  = (i_addr == 4'd8);
    assign o_decode[9]  = (i_addr == 4'd9);
    assign o_decode[10] = (i_addr == 4'd10);
    assign o_decode[11] = (i_addr == 4'd11);
    assign o_decode[12] = (i_addr == 4'd12);
    assign o_decode[13] = (i_addr == 4'd13);
    assign o_decode[14] = (i_addr == 4'd14);
    assign o_decode[15] = (i_addr == 4'd15);

endmodule