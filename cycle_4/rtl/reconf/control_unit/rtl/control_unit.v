module control_unit (
    input  wire [3:0] i_opcode,
    output wire       o_reg_write,
    output wire       o_mem_write,
    output wire       o_alu_src,      // 0:rs2, 1:imm
    output wire       o_mem_to_reg,   // 1:data from dmem
    output wire       o_reg_src_pc,   // 1:pc+2 for jal/jalr
    output wire       o_imm_load,     // 1:loadi
    output wire [3:0] o_alu_op,
    output wire       o_branch,
    output wire       o_jump,
    output wire       o_jump_reg
);

    wire [15:0] w_match;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_opcode_matches
            control_unit_opcode_match #(
                .TARGET_OPCODE(i[3:0])
            ) u_match (
                .i_opcode (i_opcode),
                .o_match  (w_match[i])
            );
        end
    endgenerate

    // Register Write: ALU(0-8), loadi(9), load(10), jal(14), jalr(15)
    assign o_reg_write = w_match[0] | w_match[1] | w_match[2] | w_match[3] | 
                         w_match[4] | w_match[5] | w_match[6] | w_match[7] | 
                         w_match[8] | w_match[9] | w_match[10] | w_match[14] | w_match[15];

    // Memory Write: store(11)
    assign o_mem_write = w_match[11];

    // ALU Source Select (Immediate): addi(8), load(10), store(11), jalr(15)
    assign o_alu_src = w_match[8] | w_match[10] | w_match[11] | w_match[15];

    // Memory to Register: load(10)
    assign o_mem_to_reg = w_match[10];

    // Register Source Select (PC+2): jal(14), jalr(15)
    assign o_reg_src_pc = w_match[14] | w_match[15];

    // Immediate Load: loadi(9)
    assign o_imm_load = w_match[9];

    // ALU Operation Code
    assign o_alu_op = i_opcode;

    // Branch Control: blt(12), bz(13)
    assign o_branch = w_match[12] | w_match[13];

    // Jump Control: jal(14)
    assign o_jump = w_match[14];

    // Jump Register Control: jalr(15)
    assign o_jump_reg = w_match[15];

endmodule