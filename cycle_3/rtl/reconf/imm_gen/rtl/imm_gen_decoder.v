module imm_gen_decoder (
    input  wire [3:0] i_opcode,
    output wire [1:0] o_sel
);

    // 即値形式のデコード
    // 00: I4 (addi, load, jalr)
    // 01: S4 (store)
    // 10: I8 (loadi, jal)
    // 11: B12 (blt, bz)

    wire w_is_i4;
    wire w_is_s4;
    wire w_is_i8;
    wire w_is_b12;

    assign w_is_i4  = (i_opcode == 4'b1000) | (i_opcode == 4'b1010) | (i_opcode == 4'b1111);
    assign w_is_s4  = (i_opcode == 4'b1011);
    assign w_is_i8  = (i_opcode == 4'b1001) | (i_opcode == 4'b1110);
    assign w_is_b12 = (i_opcode == 4'b1100) | (i_opcode == 4'b1101);

    // 選択信号(o_sel)の生成
    // セレクタ制御: Bit1(MSB), Bit0(LSB)
    assign o_sel[0] = w_is_s4 | w_is_b12;
    assign o_sel[1] = w_is_i8 | w_is_b12;

endmodule