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

    // Internal Wires
    wire [3:0]  w_rd_addr, w_rs1_addr, w_rs2_addr;
    wire        w_reg_write_en, w_alu_src_sel;
    wire [3:0]  w_alu_op;
    wire [1:0]  w_reg_src_sel;
    wire        w_is_blt, w_is_bz, w_is_jal, w_is_jalr;
    
    wire [15:0] w_rs1_data, w_rs2_data, w_rd_data;
    wire [15:0] w_imm;
    wire [1:0]  w_imm_sel;
    
    wire [15:0] w_alu_b;
    wire [15:0] w_alu_result;
    wire        w_alu_f_z, w_alu_f_n, w_alu_f_v;
    wire        w_flag_z, w_flag_n, w_flag_v;
    wire        w_flag_wen;

    wire        w_pc_sel_target, w_pc_sel_rs1;
    wire [15:0] w_pc_plus_2;
    wire [3:0]  w_opcode;

    assign w_opcode = i_instr[3:0];

    // Immediate Selection Logic (based on ISA Format)
    // 0: [7:4], 1: [15:12], 2: [11:4], 3: [15:4]
    assign w_imm_sel[0] = (w_opcode == 4'b1011) || (w_opcode == 4'b1100) || (w_opcode == 4'b1101);
    assign w_imm_sel[1] = (w_opcode == 4'b1001) || (w_opcode == 4'b1110) || (w_opcode == 4'b1100) || (w_opcode == 4'b1101);

    // Write-back Data MUX (0:ALU, 1:DMEM, 2:PC+2, 3:LOADI)
    assign w_rd_data = (w_reg_src_sel == 2'b00) ? w_alu_result :
                       (w_reg_src_sel == 2'b01) ? i_data_from_dmem :
                       (w_reg_src_sel == 2'b10) ? w_pc_plus_2 : w_imm;

    // ALU Input B MUX (0:rs2, 1:imm)
    assign w_alu_b = w_alu_src_sel ? w_imm : w_rs2_data;

    // Flag Register Update Logic (Update on Add/Sub)
    assign w_flag_wen = (w_opcode == 4'b0000) || (w_opcode == 4'b0001) || (w_opcode == 4'b1000);

    // Module Instances
    instruction_decoder u_decoder (
        .i_instr        (i_instr),
        .o_rd_addr      (w_rd_addr),
        .o_rs1_addr     (w_rs1_addr),
        .o_rs2_addr     (w_rs2_addr),
        .o_reg_write_en (w_reg_write_en),
        .o_dmem_wen     (o_dmem_wen),
        .o_alu_op       (w_alu_op),
        .o_alu_src_sel  (w_alu_src_sel),
        .o_reg_src_sel  (w_reg_src_sel),
        .o_is_blt       (w_is_blt),
        .o_is_bz        (w_is_bz),
        .o_is_jal       (w_is_jal),
        .o_is_jalr      (w_is_jalr)
    );

    register_file u_regfile (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_rd_data),
        .i_rd_wen   (w_reg_write_en),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    imm_gen u_immgen (
        .i_instr   (i_instr),
        .i_imm_sel (w_imm_sel),
        .o_imm     (w_imm)
    );

    alu u_alu (
        .i_a        (w_rs1_data),
        .i_b        (w_alu_b),
        .i_alu_op   (w_alu_op),
        .o_result   (w_alu_result),
        .o_flag_z   (w_alu_f_z),
        .o_flag_n   (w_alu_f_n),
        .o_flag_v   (w_alu_f_v)
    );

    flag_reg u_flags (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_wen   (w_flag_wen),
        .i_alu_z (w_alu_f_z),
        .i_alu_n (w_alu_f_n),
        .i_alu_v (w_alu_f_v),
        .o_flag_z(w_flag_z),
        .o_flag_n(w_flag_n),
        .o_flag_v(w_flag_v)
    );

    pc_control u_pc_ctrl (
        .i_is_blt        (w_is_blt),
        .i_is_bz         (w_is_bz),
        .i_is_jal        (w_is_jal),
        .i_is_jalr       (w_is_jalr),
        .i_flag_z        (w_flag_z),
        .i_flag_n        (w_flag_n),
        .i_flag_v        (w_flag_v),
        .o_pc_sel_target (w_pc_sel_target),
        .o_pc_sel_rs1    (w_pc_sel_rs1)
    );

    program_counter u_pc (
        .i_clk           (i_clk),
        .i_rst_n         (i_rst_n),
        .i_imm           (w_imm),
        .i_rs1_data      (w_rs1_data),
        .i_pc_sel_target (w_pc_sel_target),
        .i_pc_sel_rs1    (w_pc_sel_rs1),
        .o_pc            (o_addr_to_imem),
        .o_pc_plus_2     (w_pc_plus_2)
    );

    // Data Memory Connections
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;

    // Debug Assignments
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_rd_data;
    assign o_debug_regfile_wen    = w_reg_write_en;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = o_addr_to_dmem;
    assign o_debug_data_to_dmem   = o_data_to_dmem;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = o_addr_to_imem;
    assign o_debug_flag_n         = w_flag_n;
    assign o_debug_flag_v         = w_flag_v;
    assign o_debug_flag_z         = w_flag_z;

endmodule