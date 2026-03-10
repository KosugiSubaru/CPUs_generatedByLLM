module control_unit_op_logic (
    input  wire [15:0] i_instr_active,
    output wire [3:0]  o_alu_op,
    output wire        o_reg_write,
    output wire        o_mem_write,
    output wire        o_alu_src_sel,
    output wire [1:0]  o_wb_sel,
    output wire [1:0]  o_imm_sel,
    output wire        o_branch_en,
    output wire        o_branch_type,
    output wire        o_jump_en,
    output wire        o_jalr_sel
);

    // ALU Operation Mapping: 
    // R-type (0-7) and ADDI (8) use their opcode.
    // Load (10) and Store (11) use ADD (0).
    assign o_alu_op[0] = i_instr_active[1] | i_instr_active[3] | i_instr_active[5] | i_instr_active[7];
    assign o_alu_op[1] = i_instr_active[2] | i_instr_active[3] | i_instr_active[6] | i_instr_active[7];
    assign o_alu_op[2] = i_instr_active[4] | i_instr_active[5] | i_instr_active[6] | i_instr_active[7];
    assign o_alu_op[3] = i_instr_active[8];

    // Register Write Enable: 
    // Active for ALU R-type, ADDI, LOADI, LOAD, JAL, JALR
    assign o_reg_write = i_instr_active[0] | i_instr_active[1] | i_instr_active[2] | i_instr_active[3] |
                         i_instr_active[4] | i_instr_active[5] | i_instr_active[6] | i_instr_active[7] |
                         i_instr_active[8] | i_instr_active[9] | i_instr_active[10] | 
                         i_instr_active[14] | i_instr_active[15];

    // Data Memory Write Enable: 
    // Active only for STORE
    assign o_mem_write = i_instr_active[11];

    // ALU Source Selection: 
    // 0: rs2, 1: imm (ADDI, LOAD, STORE)
    assign o_alu_src_sel = i_instr_active[8] | i_instr_active[10] | i_instr_active[11];

    // Write Back Selector: 
    // 00: ALU result, 01: Mem data, 10: Immediate (LOADI), 11: PC+2 (JAL/JALR)
    assign o_wb_sel[0] = i_instr_active[10] | i_instr_active[14] | i_instr_active[15];
    assign o_wb_sel[1] = i_instr_active[9]  | i_instr_active[14] | i_instr_active[15];

    // Immediate Selector:
    // 00: Type 0 (4-bit [7:4])   -> ADDI(8), LOAD(10), JALR(15)
    // 01: Type 1 (8-bit [11:4])  -> LOADI(9), JAL(14)
    // 10: Type 2 (12-bit [15:4]) -> BLT(12), BZ(13)
    // 11: Type 3 (4-bit [15:12]) -> STORE(1011)
    assign o_imm_sel[0] = i_instr_active[9]  | i_instr_active[14] | i_instr_active[11];
    assign o_imm_sel[1] = i_instr_active[12] | i_instr_active[13] | i_instr_active[11];

    // Branch Control:
    assign o_branch_en   = i_instr_active[12] | i_instr_active[13];
    assign o_branch_type = i_instr_active[13]; // 0: BLT (N^V), 1: BZ (Z)

    // Jump Control:
    assign o_jump_en  = i_instr_active[14] | i_instr_active[15];
    assign o_jalr_sel = i_instr_active[15]; // 0: PC relative, 1: rs1 relative

endmodule