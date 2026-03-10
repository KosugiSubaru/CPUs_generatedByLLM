module imm_gen_mux (
    input  wire [3:0]  i_opcode,
    input  wire [15:0] i_imm_ext4_7_4,   // addi, load, jalr 用
    input  wire [15:0] i_imm_ext4_15_12, // store 用
    input  wire [15:0] i_imm_ext8,       // loadi, jal 用
    input  wire [15:0] i_imm_ext12,      // blt, bz 用
    output wire [15:0] o_imm
);

    // opcodeに基づき、適切な即値フィールドを選択
    assign o_imm = (i_opcode == 4'b1000) ? i_imm_ext4_7_4   : // addi
                   (i_opcode == 4'b1001) ? i_imm_ext8       : // loadi
                   (i_opcode == 4'b1010) ? i_imm_ext4_7_4   : // load
                   (i_opcode == 4'b1011) ? i_imm_ext4_15_12 : // store
                   (i_opcode == 4'b1100) ? i_imm_ext12      : // blt
                   (i_opcode == 4'b1101) ? i_imm_ext12      : // bz
                   (i_opcode == 4'b1110) ? i_imm_ext8       : // jal
                   (i_opcode == 4'b1111) ? i_imm_ext4_7_4   : // jalr
                                           16'h0000;

endmodule