module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,
    input  wire [15:0] i_data_from_dmem,

    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire [15:0] o_addr_to_imem,
    output wire        o_dmem_wen,

    // CPU_DEBUG_BEGIN
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
    // CPU_DEBUG_END
);

    // ---- Internal Wires ----
    wire [15:0] w_pc_current;
    wire [15:0] w_pc_next;
    wire [15:0] w_pc_plus_2;
    
    wire [3:0]  w_alu_op;
    wire        w_reg_we;
    wire        w_mem_we;
    wire        w_alu_src_sel;
    wire [1:0]  w_wb_sel;
    wire        w_branch_en;
    wire        w_branch_type;
    wire        w_jump_en;
    wire        w_jalr_sel;
    wire [1:0]  w_imm_sel;
    
    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_rd_data;
    wire [15:0] w_imm;
    
    wire [15:0] w_alu_in_b;
    wire [15:0] w_alu_result;
    wire        w_alu_z;
    wire        w_alu_n;
    wire        w_alu_v;
    
    wire        w_flag_z;
    wire        w_flag_n;
    wire        w_flag_v;

    // ---- Module Instantiations ----

    // Program Counter State
    program_counter_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_pc_next),
        .o_q     (w_pc_current)
    );

    // Next PC Logic
    pc_selector u_pc_sel (
        .i_pc_current   (w_pc_current),
        .i_imm          (w_imm),
        .i_rs1          (w_rs1_data),
        .i_flag_z       (w_flag_z),
        .i_flag_n       (w_flag_n),
        .i_flag_v       (w_flag_v),
        .i_branch_en    (w_branch_en),
        .i_branch_type  (w_branch_type),
        .i_jump_en      (w_jump_en),
        .i_jalr_sel     (w_jalr_sel),
        .o_pc_next      (w_pc_next),
        .o_pc_plus_2    (w_pc_plus_2)
    );

    // Control Unit (Updated with missing o_imm_sel port)
    control_unit u_control (
        .i_opcode      (i_instr[3:0]),
        .o_alu_op      (w_alu_op),
        .o_reg_write   (w_reg_we),
        .o_mem_write   (w_mem_we),
        .o_alu_src_sel (w_alu_src_sel),
        .o_wb_sel      (w_wb_sel),
        .o_imm_sel     (w_imm_sel),
        .o_branch_en   (w_branch_en),
        .o_branch_type (w_branch_type),
        .o_jump_en     (w_jump_en),
        .o_jalr_sel    (w_jalr_sel)
    );

    // Register File
    register_file u_regfile (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (i_instr[11:8]),
        .i_rs2_addr (i_instr[7:4]),
        .i_rd_addr  (i_instr[15:12]),
        .i_rd_data  (w_rd_data),
        .i_rd_we    (w_reg_we),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // Immediate Generator (Uses select signal from control_unit)
    immediate_generator u_imm_gen (
        .i_instr   (i_instr),
        .i_imm_sel (w_imm_sel),
        .o_imm     (w_imm)
    );

    // ALU Input Selection
    assign w_alu_in_b = (w_alu_src_sel) ? w_imm : w_rs2_data;

    // ALU Main
    alu_main u_alu (
        .i_a      (w_rs1_data),
        .i_b      (w_alu_in_b),
        .i_alu_op (w_alu_op),
        .o_result (w_alu_result),
        .o_flag_z (w_alu_z),
        .o_flag_n (w_alu_n),
        .o_flag_v (w_alu_v)
    );

    // Flag Register
    flag_register u_flag_reg (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_flag_we    (w_reg_we | w_branch_en),
        .i_alu_flag_z (w_alu_z),
        .i_alu_flag_n (w_alu_n),
        .i_alu_flag_v (w_alu_v),
        .o_flag_z     (w_flag_z),
        .o_flag_n     (w_flag_n),
        .o_flag_v     (w_flag_v)
    );

    // Write Back Selection
    assign w_rd_data = (w_wb_sel == 2'b00) ? w_alu_result      :
                       (w_wb_sel == 2'b01) ? i_data_from_dmem  :
                       (w_wb_sel == 2'b10) ? w_imm            :
                                             w_pc_plus_2;

    // ---- External IO Connections ----
    assign o_addr_to_imem   = w_pc_current;
    assign o_addr_to_dmem   = w_alu_result;
    assign o_data_to_dmem   = w_rs2_data;
    assign o_dmem_wen       = w_mem_we;

    // ---- Debug Port Connections ----
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = i_instr[11:8];
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = i_instr[7:4];
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = i_instr[15:12];
    assign o_debug_rd_data        = w_rd_data;
    assign o_debug_regfile_wen    = w_reg_we;
    assign o_debug_dmem_wen       = w_mem_we;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc_current;
    assign o_debug_flag_z         = w_flag_z;
    assign o_debug_flag_n         = w_flag_n;
    assign o_debug_flag_v         = w_flag_v;

endmodule