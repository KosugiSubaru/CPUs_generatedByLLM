module control_unit_decoder_4to16 (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_decoded
);

    // 各ビットがISA定義のopcodeと1対1で対応するようにデコード
    // 回路図上で、現在どの命令が選択されているかを16本の信号線として視覚化する
    assign o_decoded[0]  = (i_opcode == 4'b0000); // addition
    assign o_decoded[1]  = (i_opcode == 4'b0001); // subtraction
    assign o_decoded[2]  = (i_opcode == 4'b0010); // logical and
    assign o_decoded[3]  = (i_opcode == 4'b0011); // logical or
    assign o_decoded[4]  = (i_opcode == 4'b0100); // logical xor
    assign o_decoded[5]  = (i_opcode == 4'b0101); // logical not
    assign o_decoded[6]  = (i_opcode == 4'b0110); // shift right arithmetic
    assign o_decoded[7]  = (i_opcode == 4'b0111); // shift left arithmetic
    assign o_decoded[8]  = (i_opcode == 4'b1000); // add immediate
    assign o_decoded[9]  = (i_opcode == 4'b1001); // load immediate
    assign o_decoded[10] = (i_opcode == 4'b1010); // load
    assign o_decoded[11] = (i_opcode == 4'b1011); // store
    assign o_decoded[12] = (i_opcode == 4'b1100); // branch less than
    assign o_decoded[13] = (i_opcode == 4'b1101); // branch zero
    assign o_decoded[14] = (i_opcode == 4'b1110); // jump and link
    assign o_decoded[15] = (i_opcode == 4'b1111); // jump and link register

endmodule