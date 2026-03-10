module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,
    input  wire [15:0] i_data_from_dmem,

    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire [15:0] o_addr_to_imem,
    output wire        o_dmem_wen,

    // デバッグポート
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
    wire [3:0]  w_opcode;
    wire [3:0]  w_rd_addr, w_rs1_addr, w_rs2_addr;
    wire [11:0] w_imm_raw;
    wire [15:0] w_imm_data;
    
    wire [3:0]  w_alu_op;
    wire        w_alu_src_b_sel;
    wire [1:0]  w_wb_sel;
    wire        w_reg_file_wen;
    wire        w_flag_reg_wen;
    wire        w_pc_jump_taken;
    wire        w_pc_target_sel;

    wire [15:0] w_rs1_data, w_rs2_data;
    wire [15:0] w_alu_in_b;
    wire [15:0] w_alu_result;
    wire        w_alu_z, w_alu_n, w_alu_v;
    wire        w_stored_z, w_stored_n, w_stored_v;
    
    wire [15:0] w_pc_now, w_pc_plus_2;
    wire [15:0] w_wb_data;

    // 1. プログラムカウンタ (PC)
    program_counter u_pc (
        .i_clk           (i_clk),
        .i_rst_n         (i_rst_n),
        .i_imm           (w_imm_data),
        .i_rs1_data      (w_rs1_data),
        .i_pc_target_sel (w_pc_target_sel),
        .i_pc_jump_taken (w_pc_jump_taken),
        .o_pc_now        (w_pc_now),
        .o_pc_plus_2     (w_pc_plus_2)
    );
    assign o_addr_to_imem = w_pc_now;

    // 2. 命令デコーダ
    instruction_decoder u_decoder (
        .i_instr    (i_instr),
        .o_opcode   (w_opcode),
        .o_rd_addr  (w_rd_addr),
        .o_rs1_addr (w_rs1_addr),
        .o_rs2_addr (w_rs2_addr),
        .o_imm_raw  (w_imm_raw)
    );

    // 3. 即値生成器 (符号拡張)
    imm_gen u_imm_gen (
        .i_opcode   (w_opcode),
        .i_imm_raw  (w_imm_raw),
        .o_imm_16bit(w_imm_data)
    );

    // 4. フラグレジスタ (1クロック前の演算結果を保持)
    flag_reg u_flag_reg (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_en       (w_flag_reg_wen),
        .i_flag_z   (w_alu_z),
        .i_flag_n   (w_alu_n),
        .i_flag_v   (w_alu_v),
        .o_flag_z   (w_stored_z),
        .o_flag_n   (w_stored_n),
        .o_flag_v   (w_stored_v)
    );

    // 5. 制御ユニット
    control_unit u_control (
        .i_opcode        (w_opcode),
        .i_flag_z        (w_stored_z),
        .i_flag_n        (w_stored_n),
        .i_flag_v        (w_stored_v),
        .o_alu_op        (w_alu_op),
        .o_alu_src_b_sel (w_alu_src_b_sel),
        .o_wb_sel        (w_wb_sel),
        .o_reg_file_wen  (w_reg_file_wen),
        .o_dmem_wen      (o_dmem_wen),
        .o_flag_reg_wen  (w_flag_reg_wen),
        .o_pc_jump_taken (w_pc_jump_taken),
        .o_pc_target_sel (w_pc_target_sel)
    );

    // 6. レジスタファイル
    register_file u_regfile (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_wb_data),
        .i_reg_wen  (w_reg_file_wen),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // 7. ALU (演算器)
    assign w_alu_in_b = (w_alu_src_b_sel) ? w_imm_data : w_rs2_data;

    alu u_alu (
        .i_a      (w_rs1_data),
        .i_b      (w_alu_in_b),
        .i_alu_op (w_alu_op),
        .o_result (w_alu_result),
        .o_flag_z (w_alu_z),
        .o_flag_n (w_alu_n),
        .o_flag_v (w_alu_v)
    );

    // 8. データメモリインターフェース
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;

    // 9. ライトバックセレクタ
    writeback_mux u_wb_mux (
        .i_alu_result (w_alu_result),
        .i_mem_data   (i_data_from_dmem),
        .i_pc_plus_2  (w_pc_plus_2),
        .i_wb_sel     (w_wb_sel),
        .o_wb_data    (w_wb_data)
    );

    // デバッグ信号の接続
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_wb_data;
    assign o_debug_regfile_wen    = w_reg_file_wen;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = o_addr_to_dmem;
    assign o_debug_data_to_dmem   = o_data_to_dmem;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc_now;
    assign o_debug_flag_n         = w_stored_n;
    assign o_debug_flag_v         = w_stored_v;
    assign o_debug_flag_z         = w_stored_z;

endmodule