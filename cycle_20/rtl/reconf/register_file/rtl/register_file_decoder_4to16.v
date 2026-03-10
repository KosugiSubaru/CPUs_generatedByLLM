module register_file_decoder_4to16 (
    input  wire [3:0]  i_addr,
    output wire [15:0] o_decoded
);

    assign o_decoded[0]  = (i_addr == 4'd0);
    assign o_decoded[1]  = (i_addr == 4'd1);
    assign o_decoded[2]  = (i_addr == 4'd2);
    assign o_decoded[3]  = (i_addr == 4'd3);
    assign o_decoded[4]  = (i_addr == 4'd4);
    assign o_decoded[5]  = (i_addr == 4'd5);
    assign o_decoded[6]  = (i_addr == 4'd6);
    assign o_decoded[7]  = (i_addr == 4'd7);
    assign o_decoded[8]  = (i_addr == 4'd8);
    assign o_decoded[9]  = (i_addr == 4'd9);
    assign o_decoded[10] = (i_addr == 4'd10);
    assign o_decoded[11] = (i_addr == 4'd11);
    assign o_decoded[12] = (i_addr == 4'd12);
    assign o_decoded[13] = (i_addr == 4'd13);
    assign o_decoded[14] = (i_addr == 4'd14);
    assign o_decoded[15] = (i_addr == 4'd15);

endmodule