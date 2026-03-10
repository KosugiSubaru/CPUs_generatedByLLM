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
    output wire        o_debug_flag_z,
    output wire        o_debug_flag_n,
    output wire        o_debug_flag_v
);

    // 内部信号定義
    wire [15:0] w_pc_next, w_pc_plus_2, w_imm, w_rs1_data, w_rs2_data, w_alu_res, w_reg_wdata, w_alu_src_b;
    wire [3:0]  w_alu_op;
    wire [2:0]  w_imm_type; // 3ビット幅
    wire [1:0]  w_reg_res_sel, w_pc_sel;
    wire        w_reg_wen, w_alu_src_sel, w_alu_z, w_alu_n, w_alu_v, w_flag_z, w_flag_n, w_flag_v;

    // --- Control Unit ---
    control_unit u_control (
        .i_opcode      (i_instr[3:0]),
        .i_flag_z      (w_flag_z),
        .i_flag_n      (w_flag_n),
        .i_flag_v      (w_flag_v),
        .o_reg_write   (w_reg_wen),
        .o_mem_write   (o_dmem_wen),
        .o_alu_src     (w_alu_src_sel),
        .o_reg_res_sel (w_reg_res_sel),
        .o_alu_op      (w_alu_op),
        .o_imm_type    (w_imm_type), // 修正：3ビット信号をそのまま接続
        .o_pc_sel      (w_pc_sel)
    );

    // --- Program Counter ---
    program_counter u_pc (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_imm       (w_imm),
        .i_rs1_data  (w_rs1_data),
        .i_pc_sel    (w_pc_sel),
        .o_pc        (o_addr_to_imem),
        .o_pc_plus_2 (w_pc_plus_2)
    );

    // --- Register File ---
    register_file u_regfile (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_wen      (w_reg_wen),
        .i_rd_addr  (i_instr[15:12]),
        .i_rd_data  (w_reg_wdata),
        .i_rs1_addr (i_instr[11:8]),
        .i_rs2_addr (i_instr[7:4]),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // --- Immediate Generator ---
    imm_gen u_imm_gen (
        .i_instr    (i_instr),
        .i_imm_type (w_imm_type), // 修正：3ビット信号をそのまま接続
        .o_imm      (w_imm)
    );

    // --- ALU Core ---
    assign w_alu_src_b = w_alu_src_sel ? w_imm : w_rs2_data;

    alu_core u_alu (
        .i_alu_op (w_alu_op),
        .i_rs1    (w_rs1_data),
        .i_rs2    (w_alu_src_b),
        .o_res    (w_alu_res),
        .o_flag_z (w_alu_z),
        .o_flag_n (w_alu_n),
        .o_flag_v (w_alu_v)
    );

    // --- Flag Register ---
    flag_reg u_flag_reg (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_flag_wen (w_reg_wen & ~w_alu_src_sel),
        .i_flag_z   (w_alu_z),
        .i_flag_n   (w_alu_n),
        .i_flag_v   (w_alu_v),
        .o_flag_z   (w_flag_z),
        .o_flag_n   (w_flag_n),
        .o_flag_v   (w_flag_v)
    );

    // --- Write-back MUX ---
    assign w_reg_wdata = (w_reg_res_sel == 2'b00) ? w_alu_res :
                         (w_reg_res_sel == 2'b01) ? i_data_from_dmem :
                         (w_reg_res_sel == 2'b10) ? w_pc_plus_2 : w_imm;

    // --- Data Memory Interface ---
    assign o_addr_to_dmem = w_alu_res;
    assign o_data_to_dmem = w_rs2_data;

    // --- Debug Assignments ---
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = i_instr[11:8];
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = i_instr[7:4];
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = i_instr[15:12];
    assign o_debug_rd_data        = w_reg_wdata;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = o_addr_to_dmem;
    assign o_debug_data_to_dmem   = o_data_to_dmem;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = o_addr_to_imem;
    assign o_debug_flag_z         = w_flag_z;
    assign o_debug_flag_n         = w_flag_n;
    assign o_debug_flag_v         = w_flag_v;

endmodule