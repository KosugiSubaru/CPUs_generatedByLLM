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
    wire [15:0] w_now_pc;
    wire [15:0] w_next_pc;
    wire [15:0] w_pc_plus_2;

    wire [3:0]  w_opcode;
    wire [3:0]  w_rd_addr;
    wire [3:0]  w_rs1_addr;
    wire [3:0]  w_rs2_addr;
    wire [11:0] w_imm_raw_15_4;

    wire        w_reg_we;
    wire        w_alu_src_sel;
    wire [1:0]  w_wb_sel;
    wire [3:0]  w_alu_op;
    wire [1:0]  w_pc_sel;

    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_rd_data;
    wire [15:0] w_imm;

    wire [15:0] w_alu_operand_b;
    wire [15:0] w_alu_result;
    wire        w_alu_flag_z;
    wire        w_alu_flag_n;
    wire        w_alu_flag_v;

    wire        w_stored_flag_z;
    wire        w_stored_flag_n;
    wire        w_stored_flag_v;

    // --- Module Instantiations ---

    // PC Register
    pc_reg u_pc_reg (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_next_pc (w_next_pc),
        .o_now_pc  (w_now_pc)
    );

    // Instruction Decoder
    inst_decoder u_inst_decoder (
        .i_instr        (i_instr),
        .o_opcode       (w_opcode),
        .o_rd_addr      (w_rd_addr),
        .o_rs1_addr     (w_rs1_addr),
        .o_rs2_addr     (w_rs2_addr),
        .o_imm_raw_15_4 (w_imm_raw_15_4)
    );

    // Control Unit
    control_unit u_control_unit (
        .i_opcode      (w_opcode),
        .i_flag_z      (w_stored_flag_z),
        .i_flag_n      (w_stored_flag_n),
        .i_flag_v      (w_stored_flag_v),
        .o_reg_we      (w_reg_we),
        .o_mem_we      (o_dmem_wen),
        .o_alu_src_sel (w_alu_src_sel),
        .o_wb_sel      (w_wb_sel),
        .o_alu_op      (w_alu_op),
        .o_pc_sel      (w_pc_sel)
    );

    // Register File
    register_file u_register_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_rd_data),
        .i_we       (w_reg_we),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // Immediate Generation
    imm_gen u_imm_gen (
        .i_opcode       (w_opcode),
        .i_rd_addr      (w_rd_addr),
        .i_rs2_addr     (w_rs2_addr),
        .i_imm_raw_15_4 (w_imm_raw_15_4),
        .o_imm          (w_imm)
    );

    // ALU Operand B Selection
    assign w_alu_operand_b = (w_alu_src_sel) ? w_imm : w_rs2_data;

    // ALU
    alu_16bit u_alu_16bit (
        .i_a      (w_rs1_data),
        .i_b      (w_alu_operand_b),
        .i_opcode (w_alu_op),
        .o_result (w_alu_result),
        .o_flag_z (w_alu_flag_z),
        .o_flag_n (w_alu_flag_n),
        .o_flag_v (w_alu_flag_v)
    );

    // Flag Register (Updates flags for the next instruction)
    flag_reg u_flag_reg (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_flag_z_alu (w_alu_flag_z),
        .i_flag_n_alu (w_alu_flag_n),
        .i_flag_v_alu (w_alu_flag_v),
        .o_flag_z     (w_stored_flag_z),
        .o_flag_n     (w_stored_flag_n),
        .o_flag_v     (w_stored_flag_v)
    );

    // Write-Back Data Selection
    assign w_rd_data = (w_wb_sel == 2'b00) ? w_alu_result :
                       (w_wb_sel == 2'b01) ? i_data_from_dmem :
                       (w_wb_sel == 2'b10) ? w_imm :
                                             w_pc_plus_2;

    // Next PC Logic
    next_pc_logic u_next_pc_logic (
        .i_now_pc    (w_now_pc),
        .i_imm       (w_imm),
        .i_rs1_data  (w_rs1_data),
        .i_pc_sel    (w_pc_sel),
        .o_next_pc   (w_next_pc),
        .o_pc_plus_2 (w_pc_plus_2)
    );

    // --- Output Assignments ---
    assign o_addr_to_imem = w_now_pc;
    assign o_addr_to_dmem = w_alu_result; // rs1 + imm
    assign o_data_to_dmem = w_rs2_data;

    // --- Debug Output Assignments ---
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_rd_data;
    assign o_debug_regfile_wen    = w_reg_we;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = o_addr_to_dmem;
    assign o_debug_data_to_dmem   = o_data_to_dmem;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_now_pc;
    assign o_debug_flag_z         = w_stored_flag_z;
    assign o_debug_flag_n         = w_stored_flag_n;
    assign o_debug_flag_v         = w_stored_flag_v;

endmodule