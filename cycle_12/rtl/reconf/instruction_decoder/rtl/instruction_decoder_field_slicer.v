module instruction_decoder_field_slicer (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_nibble_0, // [3:0]   : Opcode
    output wire [3:0]  o_nibble_1, // [7:4]   : Rs2 / Imm / Opcode Ext
    output wire [3:0]  o_nibble_2, // [11:8]  : Rs1 / Imm
    output wire [3:0]  o_nibble_3  // [15:12] : Rd / Imm
);

    assign o_nibble_0 = i_instr[3:0];
    assign o_nibble_1 = i_instr[7:4];
    assign o_nibble_2 = i_instr[11:8];
    assign o_nibble_3 = i_instr[15:12];

endmodule