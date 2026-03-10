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

    // --- 内部配線定義 ---
    wire [15:0] w_pc_now;
    wire [15:0] w_pc_p2, w_pc_br, w_pc_jr;
    wire [1:0]  w_pc_sel;

    wire [3:0]  w_alu_op;
    wire        w_reg_wen, w_dmem_wen, w_alu_src_sel;
    wire [1:0]  w_wb_sel;
    wire        w_is_blt, w_is_bz, w_is_jump_imm, w_is_jump_reg;

    wire [15:0] w_rs1_data, w_rs2_data, w_wb_data;
    wire [15:0] w_imm;
    wire [15:0] w_alu_in2;
    wire [15:0] w_alu_result;

    wire        w_f_z_new, w_f_n_new, w_f_v_new;
    wire        w_f_z_old, w_f_n_old, w_f_v_old;

    // --- サブモジュールのインスタンス化 ---

    // 1. プログラムカウンタ
    pc_reg u_pc_reg (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_pc_sel    (w_pc_sel),
        .i_pc_plus_2 (w_pc_p2),
        .i_pc_branch (w_pc_br),
        .i_pc_jalr   (w_pc_jr),
        .o_pc        (w_pc_now)
    );

    // 2. コントロールユニット
    control_unit u_control_unit (
        .i_opcode        (i_instr[3:0]),
        .o_alu_op        (w_alu_op),
        .o_reg_wen       (w_reg_wen),
        .o_dmem_wen      (w_dmem_wen),
        .o_alu_src_sel   (w_alu_src_sel),
        .o_wb_sel        (w_wb_sel),
        .o_is_branch_blt (w_is_blt),
        .o_is_branch_bz  (w_is_bz),
        .o_is_jump_imm   (w_is_jump_imm),
        .o_is_jump_reg   (w_is_jump_reg)
    );

    // 3. 即値生成ユニット
    imm_gen u_imm_gen (
        .i_instr (i_instr),
        .o_imm   (w_imm)
    );

    // 4. レジスタファイル
    register_file u_register_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (i_instr[11:8]),
        .i_rs2_addr (i_instr[7:4]),
        .i_rd_addr  (i_instr[15:12]),
        .i_rd_data  (w_wb_data),
        .i_rd_wen   (w_reg_wen),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // 5. ALU入力選択MUX
    alu_mux u_alu_mux (
        .i_sel  (w_alu_src_sel),
        .i_d0   (w_rs2_data),
        .i_d1   (w_imm),
        .o_data (w_alu_in2)
    );

    // 6. 演算器 (ALU)
    alu u_alu (
        .i_opcode     (w_alu_op),
        .i_rs1_data   (w_rs1_data),
        .i_rs2_data   (w_alu_in2),
        .o_alu_result (w_alu_result),
        .o_flag_z     (w_f_z_new),
        .o_flag_n     (w_f_n_new),
        .o_flag_v     (w_f_v_new)
    );

    // 7. フラグレジスタ (1クロック前のフラグを保持)
    flag_reg u_flag_reg (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_wen       (1'b1), // 毎サイクル更新
        .i_flags_in  ({w_f_z_new, w_f_n_new, w_f_v_new}),
        .o_flags_out ({w_f_z_old, w_f_n_old, w_f_v_old})
    );

    // 8. 書き戻しデータ選択MUX
    write_back_mux u_write_back_mux (
        .i_sel       (w_wb_sel),
        .i_alu_res   (w_alu_result),
        .i_mem_data  (i_data_from_dmem),
        .i_pc_plus_2 (w_pc_p2),
        .i_imm_data  (w_imm),
        .o_wb_data   (w_wb_data)
    );

    // 9. PC制御ユニット (次アドレス計算・選択)
    pc_control u_pc_control (
        .i_pc         (w_pc_now),
        .i_imm        (w_imm),
        .i_rs1_data   (w_rs1_data),
        .i_is_blt     (w_is_blt),
        .i_is_bz      (w_is_bz),
        .i_is_jump_imm(w_is_jump_imm),
        .i_is_jump_reg(w_is_jump_reg),
        .i_flag_z     (w_f_z_old),
        .i_flag_n     (w_f_n_old),
        .i_flag_v     (w_f_v_old),
        .o_pc_plus_2  (w_pc_p2),
        .o_pc_branch  (w_pc_br),
        .o_pc_jalr    (w_pc_jr),
        .o_pc_sel     (w_pc_sel)
    );

    // --- 外部出力接続 ---
    assign o_addr_to_imem   = w_pc_now;
    assign o_addr_to_dmem   = w_alu_result;
    assign o_data_to_dmem   = w_rs2_data;
    assign o_dmem_wen       = w_dmem_wen;

    // --- デバッグ信号出力 ---
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = i_instr[11:8];
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = i_instr[7:4];
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = i_instr[15:12];
    assign o_debug_rd_data        = w_wb_data;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = w_dmem_wen;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc_now;
    assign o_debug_flag_n         = w_f_n_old;
    assign o_debug_flag_v         = w_f_v_old;
    assign o_debug_flag_z         = w_f_z_old;

endmodule