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

    // --- 内部ワイヤ定義 ---
    wire [15:0] w_pc_current, w_pc_next, w_pc_plus_2;
    wire [15:0] w_rs1_data, w_rs2_data, w_rd_data;
    wire [3:0]  w_rs1_addr, w_rs2_addr, w_rd_addr;
    wire        w_reg_wen;
    wire [3:0]  w_alu_op;
    wire        w_alu_src_b_sel;
    wire [1:0]  w_reg_wb_sel;
    wire [1:0]  w_pc_sel;
    wire [15:0] w_imm;
    wire [1:0]  w_imm_sel;
    wire [15:0] w_alu_b;
    wire [15:0] w_alu_result;
    wire        w_alu_z, w_alu_n, w_alu_v;
    wire        w_flag_z, w_flag_n, w_flag_v;

    // --- Program Counter (PC) レジスタ ---
    program_counter_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_data  (w_pc_next),
        .o_data  (w_pc_current)
    );

    // --- Control Unit ---
    control_unit u_control (
        .i_instr        (i_instr),
        .i_flag_z       (w_flag_z),
        .i_flag_n       (w_flag_n),
        .i_flag_v       (w_flag_v),
        .o_reg_rs1_addr (w_rs1_addr),
        .o_reg_rs2_addr (w_rs2_addr),
        .o_reg_rd_addr  (w_rd_addr),
        .o_reg_file_wen (w_reg_wen),
        .o_alu_op       (w_alu_op),
        .o_alu_src_b_sel(w_alu_src_b_sel),
        .o_dmem_wen     (o_dmem_wen),
        .o_reg_wb_sel   (w_reg_wb_sel),
        .o_pc_sel       (w_pc_sel)
    );

    // --- Register File ---
    register_file u_regfile (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_rd_data),
        .i_wen      (w_reg_wen),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // --- Immediate Generator ---
    assign w_imm_sel[0] = (i_instr[3:0] == 4'd11) || (i_instr[3:0] == 4'd12) || (i_instr[3:0] == 4'd13);
    assign w_imm_sel[1] = (i_instr[3:0] == 4'd9) || (i_instr[3:0] == 4'd14) || (i_instr[3:0] == 4'd12) || (i_instr[3:0] == 4'd13);

    imm_gen u_imm_gen (
        .i_instr   (i_instr),
        .i_imm_sel (w_imm_sel),
        .o_imm     (w_imm)
    );

    // --- ALU ---
    assign w_alu_b = (w_alu_src_b_sel) ? w_imm : w_rs2_data;

    alu u_alu (
        .i_a      (w_rs1_data),
        .i_b      (w_alu_b),
        .i_opcode (w_alu_op),
        .o_result (w_alu_result),
        .o_flag_z (w_alu_z),
        .o_flag_n (w_alu_n),
        .o_flag_v (w_alu_v)
    );

    // --- Flag Register ---
    flag_reg u_flag_reg (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_flag_wen (1'b1), 
        .i_flag_z   (w_alu_z),
        .i_flag_n   (w_alu_n),
        .i_flag_v   (w_alu_v),
        .o_flag_z   (w_flag_z),
        .o_flag_n   (w_flag_n),
        .o_flag_v   (w_flag_v)
    );

    // --- Next PC Logic ---
    next_pc_logic u_next_pc (
        .i_pc       (w_pc_current),
        .i_imm      (w_imm),
        .i_rs1_data (w_rs1_data),
        .i_opcode   (i_instr[3:0]), // 欠落していたOpcode接続を追加
        .i_pc_sel   (w_pc_sel),
        .i_flag_z   (w_flag_z),
        .i_flag_n   (w_flag_n),
        .i_flag_v   (w_flag_v),
        .o_next_pc  (w_pc_next)
    );
    
    assign w_pc_plus_2 = w_pc_current + 16'h0002;

    // --- Write Back Selector ---
    writeback_mux u_wb_mux (
        .i_alu_result (w_alu_result),
        .i_mem_data   (i_data_from_dmem),
        .i_pc_plus_2  (w_pc_plus_2),
        .i_wb_sel     (w_reg_wb_sel),
        .o_wb_data    (w_rd_data)
    );

    // --- 外部出力 ---
    assign o_addr_to_imem = w_pc_current;
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;

    // --- デバッグポート ---
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_rd_data;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc_current;
    assign o_debug_flag_z         = w_flag_z;
    assign o_debug_flag_n         = w_flag_n;
    assign o_debug_flag_v         = w_flag_v;

endmodule