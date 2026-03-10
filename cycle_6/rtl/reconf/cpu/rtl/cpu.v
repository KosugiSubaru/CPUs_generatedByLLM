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

    // 内部ワイヤ定義
    wire [15:0] w_pc;
    wire [15:0] w_pc_plus_2;
    wire [1:0]  w_pc_sel_cu;
    wire [1:0]  w_pc_sel_final;
    
    wire [3:0]  w_alu_op;
    wire        w_reg_write;
    wire        w_mem_write;
    wire        w_alu_src_sel;
    wire [1:0]  w_mem_to_reg;
    
    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_rd_data;
    wire [15:0] w_imm;
    wire [1:0]  w_imm_type;
    
    wire [15:0] w_alu_src_b;
    wire [15:0] w_alu_result;
    wire        w_alu_f_z, w_alu_f_n, w_alu_f_v;
    wire        w_reg_f_z, w_reg_f_n, w_reg_f_v;
    
    wire        w_branch_taken;
    wire        w_is_blt, w_is_bz;

    // --- 1. Program Counter & Next PC Logic ---
    assign w_is_blt = (i_instr[3:0] == 4'b1100);
    assign w_is_bz  = (i_instr[3:0] == 4'b1101);

    // 条件判定（フラグを参照）
    next_pc_logic_branch_resolver u_branch_resolver (
        .i_is_blt (w_is_blt),
        .i_is_bz  (w_is_bz),
        .i_flag_z (w_reg_f_z),
        .i_flag_n (w_reg_f_n),
        .i_flag_v (w_reg_f_v),
        .o_taken  (w_branch_taken)
    );

    // 最終的なPC選択信号の決定
    // 命令がBranch(01)であっても、条件不成立(!w_branch_taken)ならPC+2(00)を選択する
    assign w_pc_sel_final = (w_pc_sel_cu == 2'b01) ? (w_branch_taken ? 2'b01 : 2'b00) : w_pc_sel_cu;

    program_counter u_program_counter (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_pc_sel    (w_pc_sel_final),
        .i_imm       (w_imm),
        .i_rs1_data  (w_rs1_data),
        .o_pc        (w_pc),
        .o_pc_plus_2 (w_pc_plus_2)
    );

    assign o_addr_to_imem = w_pc;

    // --- 2. Control Unit ---
    control_unit u_control_unit (
        .i_opcode      (i_instr[3:0]),
        .i_flag_z      (w_reg_f_z),
        .i_flag_n      (w_reg_f_n),
        .i_flag_v      (w_reg_f_v),
        .o_reg_write   (w_reg_write),
        .o_mem_write   (w_mem_write),
        .o_alu_op      (w_alu_op),
        .o_alu_src_sel (w_alu_src_sel),
        .o_mem_to_reg  (w_mem_to_reg),
        .o_pc_sel      (w_pc_sel_cu)
    );

    // --- 3. Register File ---
    register_file u_register_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (i_instr[11:8]),
        .i_rs2_addr (i_instr[7:4]),
        .i_rd_addr  (i_instr[15:12]),
        .i_rd_data  (w_rd_data),
        .i_wen      (w_reg_write),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // --- 4. Immediate Generator ---
    assign w_imm_type = (i_instr[3:0] == 4'b1011) ? 2'b01 : // store
                        (i_instr[3:0] == 4'b1001 || i_instr[3:0] == 4'b1110) ? 2'b10 : // loadi, jal
                        (i_instr[3:0] == 4'b1100 || i_instr[3:0] == 4'b1101) ? 2'b11 : // branch
                        2'b00;

    imm_gen u_imm_gen (
        .i_instr    (i_instr),
        .i_imm_type (w_imm_type),
        .o_imm      (w_imm)
    );

    // --- 5. ALU ---
    assign w_alu_src_b = (w_alu_src_sel) ? w_imm : w_rs2_data;

    alu u_alu (
        .i_alu_op (w_alu_op),
        .i_src_a  (w_rs1_data),
        .i_src_b  (w_alu_src_b),
        .o_result (w_alu_result),
        .o_flag_z (w_alu_f_z),
        .o_flag_n (w_alu_f_n),
        .o_flag_v (w_alu_f_v)
    );

    // --- 6. Flag Register ---
    flag_reg u_flag_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_z     (w_alu_f_z),
        .i_n     (w_alu_f_n),
        .i_v     (w_alu_f_v),
        .o_z     (w_reg_f_z),
        .o_n     (w_reg_f_n),
        .o_v     (w_reg_f_v)
    );

    // --- 7. Memory Interface & Write Back ---
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;
    assign o_dmem_wen     = w_mem_write;

    assign w_rd_data = (w_mem_to_reg == 2'b00) ? w_alu_result :
                       (w_mem_to_reg == 2'b01) ? i_data_from_dmem :
                       w_pc_plus_2;

    // --- 8. Debug Port Mapping ---
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = i_instr[11:8];
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = i_instr[7:4];
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = i_instr[15:12];
    assign o_debug_rd_data        = w_rd_data;
    assign o_debug_regfile_wen    = w_reg_write;
    assign o_debug_dmem_wen       = w_mem_write;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc;
    assign o_debug_flag_n         = w_reg_f_n;
    assign o_debug_flag_v         = w_reg_f_v;
    assign o_debug_flag_z         = w_reg_f_z;

endmodule