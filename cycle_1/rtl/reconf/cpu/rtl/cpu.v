module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,
    input  wire [15:0] i_data_from_dmem,

    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire [15:0] o_addr_to_imem,
    output wire        o_dmem_wen,

    // Debug Ports
    output wire [15:0] o_debug_instr,
    output wire [3:0]  o_debug_rs1_addr,
    output wire [15:0] o_debug_rs1_data,
    output wire [3:0]  o_debug_rs2_addr,
    output wire [15:0] o_debug_rs2_data,
    output wire [3:0]  o_debug_rd_addr,
    output wire [15:0] o_debug_rd_data,
    output wire        o_debug_regfile_wen,
    output wire        o_debug_dmem_wen,
    output wire [15:0] o_debug_adder_to_dmem,
    output wire [15:0] o_debug_data_to_dmem,
    output wire [15:0] o_debug_data_from_dmem,
    output wire [15:0] o_debug_now_pc,
    output wire        o_debug_flag_n,
    output wire        o_debug_flag_v,
    output wire        o_debug_flag_z
);

    // --- Internal Wires ---

    // Instruction Decoder
    wire [3:0]  w_rd_addr, w_rs1_addr, w_rs2_addr;
    wire [11:0] w_imm_raw;
    wire [3:0]  w_alu_op;
    wire        w_reg_wen, w_mem_wen, w_alu_src_b_imm;
    wire [1:0]  w_reg_data_wb_sel;
    wire        w_is_blt, w_is_bz, w_is_jal, w_is_jalr;

    // Register File
    wire [15:0] w_rs1_data, w_rs2_data;
    wire [15:0] w_reg_wb_data;

    // Immediate Generator
    wire [15:0] w_imm_ext;
    wire [1:0]  w_imm_type_sel;

    // ALU
    wire [15:0] w_alu_result;
    wire [15:0] w_alu_src_b;
    wire        w_alu_flag_z, w_alu_flag_n, w_alu_flag_v;

    // Flag Register
    wire        w_stored_z, w_stored_n, w_stored_v;
    wire        w_flag_wen;

    // PC Control
    wire [1:0]  w_pc_next_sel;
    wire [15:0] w_pc_plus_2;

    // --- Submodule Instantiations ---

    // 1. Program Counter
    program_counter u_pc (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_pc_sel      (w_pc_next_sel),
        .i_imm         (w_imm_ext),
        .i_rs1_data    (w_rs1_data),
        .o_pc_current  (o_addr_to_imem),
        .o_pc_plus_2   (w_pc_plus_2)
    );

    // 2. Instruction Decoder
    instruction_decoder u_decoder (
        .i_instr         (i_instr),
        .o_rd_addr       (w_rd_addr),
        .o_rs1_addr      (w_rs1_addr),
        .o_rs2_addr      (w_rs2_addr),
        .o_imm_raw       (w_imm_raw),
        .o_alu_op        (w_alu_op),
        .o_reg_wen       (w_reg_wen),
        .o_mem_wen       (w_mem_wen),
        .o_alu_src_b_imm (w_alu_src_b_imm),
        .o_reg_data_sel  (w_reg_data_wb_sel),
        .o_branch_blt    (w_is_blt),
        .o_branch_bz     (w_is_bz),
        .o_jump_jal      (w_is_jal),
        .o_jump_jalr     (w_is_jalr)
    );

    // 3. Register File
    register_file u_rf (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_reg_wb_data),
        .i_rd_wen   (w_reg_wen),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // 4. Immediate Generator
    // 即値形式の判定 (00:I, 01:S, 10:L, 11:B)
    assign w_imm_type_sel[0] = w_mem_wen | w_is_blt | w_is_bz; // S type or B type
    assign w_imm_type_sel[1] = (w_reg_data_wb_sel == 2'b11) | w_is_jal | w_is_blt | w_is_bz; // L type or B type

    immediate_generator u_imm_gen (
        .i_imm_raw (w_imm_raw),
        .i_imm_sel (w_imm_type_sel),
        .o_imm_ext (w_imm_ext)
    );

    // 5. ALU Core
    assign w_alu_src_b = (w_alu_src_b_imm) ? w_imm_ext : w_rs2_data;

    alu_core u_alu (
        .i_a        (w_rs1_data),
        .i_b        (w_alu_src_b),
        .i_alu_op   (w_alu_op),
        .o_result   (w_alu_result),
        .o_flag_z   (w_alu_flag_z),
        .o_flag_n   (w_alu_flag_n),
        .o_flag_v   (w_alu_flag_v)
    );

    // 6. Flag Register
    // フラグ更新条件: 加減算・論理・シフト演算命令 (Opcode 0x0 ~ 0x8)
    assign w_flag_wen = (w_alu_op <= 4'h8);

    flag_register u_flags (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_flag_wen (w_flag_wen),
        .i_alu_z    (w_alu_flag_z),
        .i_alu_n    (w_alu_flag_n),
        .i_alu_v    (w_alu_flag_v),
        .o_flag_z   (w_stored_z),
        .o_flag_n   (w_stored_n),
        .o_flag_v   (w_stored_v)
    );

    // 7. PC Control Logic
    pc_control_logic u_pc_ctrl (
        .i_is_blt  (w_is_blt),
        .i_is_bz   (w_is_bz),
        .i_is_jal  (w_is_jal),
        .i_is_jalr (w_is_jalr),
        .i_flag_z  (w_stored_z),
        .i_flag_n  (w_stored_n),
        .i_flag_v  (w_stored_v),
        .o_pc_sel  (w_pc_next_sel)
    );

    // --- Output Assignments ---

    // Data Memory Interface
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;
    assign o_dmem_wen     = w_mem_wen;

    // Register File Write Back Data Mux
    // 00: ALU, 01: Memory, 10: PC+2, 11: Immediate(loadi)
    assign w_reg_wb_data = (w_reg_data_wb_sel == 2'b00) ? w_alu_result :
                           (w_reg_data_wb_sel == 2'b01) ? i_data_from_dmem :
                           (w_reg_data_wb_sel == 2'b10) ? w_pc_plus_2 : w_imm_ext;

    // --- Debug Output Assignments ---
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_reg_wb_data;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = w_mem_wen;
    assign o_debug_adder_to_dmem  = o_addr_to_dmem;
    assign o_debug_data_to_dmem   = o_data_to_dmem;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = o_addr_to_imem;
    assign o_debug_flag_z         = w_stored_z;
    assign o_debug_flag_n         = w_stored_n;
    assign o_debug_flag_v         = w_stored_v;

endmodule