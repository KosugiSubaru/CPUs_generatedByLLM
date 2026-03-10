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

    // --- 内部ワイヤ定義 ---
    wire [15:0] w_pc;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_next_pc;

    wire        w_reg_write;
    wire        w_mem_write;
    wire        w_alu_src;
    wire [3:0]  w_alu_op;
    wire [1:0]  w_result_src;
    wire        w_branch_bz;
    wire        w_branch_blt;
    wire        w_jump;
    wire        w_jump_reg;

    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_imm;
    wire [15:0] w_alu_b;
    wire [15:0] w_alu_result;
    wire [15:0] w_wb_data;

    wire        w_alu_z, w_alu_n, w_alu_v;
    wire        w_reg_z, w_reg_n, w_reg_v;
    wire        w_flag_wen;

    // --- 命令フェッチ領域 ---
    program_counter u_pc (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_next_pc   (w_next_pc),
        .o_pc        (w_pc),
        .o_pc_plus_2 (w_pc_plus_2)
    );

    assign o_addr_to_imem = w_pc;

    // --- デコード・制御領域 ---
    control_unit u_control (
        .i_opcode     (i_instr[3:0]),
        .o_reg_write  (w_reg_write),
        .o_mem_write  (w_mem_write),
        .o_alu_src    (w_alu_src),
        .o_alu_op     (w_alu_op),
        .o_result_src (w_result_src),
        .o_branch_bz  (w_branch_bz),
        .o_branch_blt (w_branch_blt),
        .o_jump       (w_jump),
        .o_jump_reg   (w_jump_reg)
    );

    register_file u_regfile (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_wen      (w_reg_write),
        .i_rd_addr  (i_instr[15:12]),
        .i_rd_data  (w_wb_data),
        .i_rs1_addr (i_instr[11:8]),
        .i_rs2_addr (i_instr[7:4]),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    imm_gen u_imm_gen (
        .i_instr (i_instr),
        .o_imm   (w_imm)
    );

    // --- 実行領域 (ALU) ---
    assign w_alu_b = (w_alu_src) ? w_imm : w_rs2_data;

    alu u_alu (
        .i_rs1_data (w_rs1_data),
        .i_rs2_data (w_alu_b),
        .i_alu_op   (w_alu_op),
        .o_result   (w_alu_result),
        .o_flag_z   (w_alu_z),
        .o_flag_n   (w_alu_n),
        .o_flag_v   (w_alu_v)
    );

    // フラグ更新制御: 加減算・論理・シフト(Opcode 0〜8)の時のみ更新
    assign w_flag_wen = (i_instr[3:0] <= 4'b1000);

    flag_reg u_flag_reg (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_wen       (w_flag_wen),
        .i_alu_flags ({w_alu_v, w_alu_n, w_alu_z}),
        .o_flag_z    (w_reg_z),
        .o_flag_n    (w_reg_n),
        .o_flag_v    (w_reg_v)
    );

    // --- メモリアクセス領域 ---
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;
    assign o_dmem_wen     = w_mem_write;

    // --- ライトバック領域 ---
    wb_mux u_wb_mux (
        .i_alu_result (w_alu_result),
        .i_mem_data   (i_data_from_dmem),
        .i_pc_plus_2  (w_pc_plus_2),
        .i_imm_data   (w_imm),
        .i_result_src (w_result_src),
        .o_wb_data    (w_wb_data)
    );

    // --- PC更新領域 ---
    pc_calc u_pc_calc (
        .i_pc         (w_pc),
        .i_pc_plus_2  (w_pc_plus_2),
        .i_rs1_data   (w_rs1_data),
        .i_imm        (w_imm),
        .i_flag_z     (w_reg_z),
        .i_flag_n     (w_reg_n),
        .i_flag_v     (w_reg_v),
        .i_branch_bz  (w_branch_bz),
        .i_branch_blt (w_branch_blt),
        .i_jump       (w_jump),
        .i_jump_reg   (w_jump_reg),
        .o_next_pc    (w_next_pc)
    );

    // --- デバッグポート接続 ---
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = i_instr[11:8];
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = i_instr[7:4];
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = i_instr[15:12];
    assign o_debug_rd_data        = w_wb_data;
    assign o_debug_regfile_wen    = w_reg_write;
    assign o_debug_dmem_wen       = w_mem_write;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc;
    assign o_debug_flag_n         = w_reg_n;
    assign o_debug_flag_v         = w_reg_v;
    assign o_debug_flag_z         = w_reg_z;

endmodule