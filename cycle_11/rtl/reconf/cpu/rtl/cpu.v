module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,
    input  wire [15:0] i_data_from_dmem,

    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire [15:0] o_addr_to_imem,
    output wire        o_dmem_wen,

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

    wire [3:0]  w_rd_addr, w_rs1_addr, w_rs2_addr, w_alu_op;
    wire [11:0] w_imm_fields; // ポート接続用に追加
    wire [15:0] w_imm, w_rs1_data, w_rs2_data, w_alu_operand_b, w_alu_result, w_wb_data;
    wire [15:0] w_pc, w_pc_plus_2, w_next_pc;
    wire [15:0] w_pc_target, w_rs1_target;
    wire        w_alu_src_b_sel, w_reg_write_en, w_mem_write_en, w_mem_to_reg, w_is_branch, w_is_jump_link;
    wire [1:0]  w_pc_src_sel;
    wire [1:0]  w_imm_sel;   
    wire [1:0]  w_wb_data_sel; 
    wire        w_f_z, w_f_n, w_f_v;
    wire        w_reg_f_z, w_reg_f_n, w_reg_f_v;

    instruction_decoder u_decoder (
        .i_instr        (i_instr),
        .o_rd_addr      (w_rd_addr),
        .o_rs1_addr     (w_rs1_addr),
        .o_rs2_addr     (w_rs2_addr),
        .o_imm_fields   (w_imm_fields),   // 修正：欠落していたピンを追加
        .o_alu_op       (w_alu_op),
        .o_alu_src_b    (w_alu_src_b_sel),
        .o_reg_write_en (w_reg_write_en),
        .o_mem_write_en (w_mem_write_en),
        .o_mem_to_reg   (w_mem_to_reg),
        .o_pc_src_sel   (w_pc_src_sel),
        .o_imm_sel      (w_imm_sel),      
        .o_wb_sel       (w_wb_data_sel),   
        .o_is_branch    (w_is_branch),
        .o_is_jump_link (w_is_jump_link)
    );

    imm_generator u_imm_gen (
        .i_instr   (i_instr),
        .i_imm_sel (w_imm_sel), 
        .o_imm     (w_imm)
    );

    register_file u_regfile (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_wb_data),
        .i_wen      (w_reg_write_en),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    alu_src_selector u_alu_src_sel (
        .i_alu_src_b_sel (w_alu_src_b_sel),
        .i_rs2_data      (w_rs2_data),
        .i_imm_data      (w_imm),
        .o_alu_operand_b (w_alu_operand_b)
    );

    alu_core u_alu (
        .i_alu_op    (w_alu_op),
        .i_operand_a (w_rs1_data),
        .i_operand_b (w_alu_operand_b),
        .o_result    (w_alu_result),
        .o_flag_z    (w_f_z),
        .o_flag_n    (w_f_n),
        .o_flag_v    (w_f_v)
    );

    flag_register u_flag_reg (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_wen    (w_reg_write_en),
        .i_flag_z (w_f_z),
        .i_flag_n (w_f_n),
        .i_flag_v (w_f_v),
        .o_flag_z (w_reg_f_z),
        .o_flag_n (w_reg_f_n),
        .o_flag_v (w_reg_f_v)
    );

    pc_adder u_pc_plus_2_adder (
        .i_a   (w_pc),
        .i_b   (16'h0002),
        .o_sum (w_pc_plus_2)
    );

    pc_adder u_pc_target_adder (
        .i_a   (w_pc),
        .i_b   (w_imm),
        .o_sum (w_pc_target)
    );

    pc_adder u_rs1_target_adder (
        .i_a   (w_rs1_data),
        .i_b   (w_imm),
        .o_sum (w_rs1_target)
    );

    next_pc_selector u_next_pc_sel (
        .i_opcode      (i_instr[3:0]),
        .i_flag_z      (w_reg_f_z),
        .i_flag_n      (w_reg_f_n),
        .i_flag_v      (w_reg_f_v),
        .i_pc_src_sel  (w_pc_src_sel),
        .i_is_branch   (w_is_branch),
        .i_pc_plus_2   (w_pc_plus_2),
        .i_pc_target   (w_pc_target),
        .i_rs1_target  (w_rs1_target),
        .o_next_pc     (w_next_pc)
    );

    program_counter_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_next_pc),
        .o_q     (w_pc)
    );

    assign o_addr_to_imem = w_pc;

    dmem_interface_logic u_dmem_logic (
        .i_rs1_data     (w_rs1_data),
        .i_rs2_data     (w_rs2_data),
        .i_imm_data     (w_imm),
        .i_mem_write_en (w_mem_write_en),
        .o_addr_to_dmem (o_addr_to_dmem),
        .o_data_to_dmem (o_data_to_dmem),
        .o_dmem_wen     (o_dmem_wen)
    );

    reg_write_data_selector u_wb_sel (
        .i_wb_sel    (w_wb_data_sel), 
        .i_alu_res   (w_alu_result),
        .i_mem_data  (i_data_from_dmem),
        .i_pc_plus_2 (w_pc_plus_2),
        .i_imm_data  (w_imm),
        .o_wb_data   (w_wb_data)
    );

    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_wb_data;
    assign o_debug_regfile_wen    = w_reg_write_en;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = o_addr_to_dmem;
    assign o_debug_data_to_dmem   = o_data_to_dmem;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc;
    assign o_debug_flag_n         = w_reg_f_n;
    assign o_debug_flag_v         = w_reg_f_v;
    assign o_debug_flag_z         = w_reg_f_z;

endmodule