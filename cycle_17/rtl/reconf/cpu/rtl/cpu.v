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
    output wire  [3:0] o_debug_rs1_addr,
    output wire [15:0] o_debug_rs1_data,
    output wire  [3:0] o_debug_rs2_addr,
    output wire [15:0] o_debug_rs2_data,
    output wire  [3:0] o_debug_rd_addr,
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

    // ---- 内部ワイヤ定義 ----
    // Decoder 関連
    wire [3:0] w_rd_addr, w_rs1_addr, w_rs2_addr;
    wire       w_reg_write, w_mem_write, w_mem_read, w_alu_src_b;
    wire [3:0] w_alu_op;
    wire [1:0] w_reg_src;
    wire       w_pc_target_src, w_jump_uncond, w_branch_bz, w_branch_blt, w_flag_we;

    // Data Path 関連
    wire [15:0] w_pc, w_pc_plus_2;
    wire [15:0] w_imm;
    wire [15:0] w_rs1_data, w_rs2_data;
    wire [15:0] w_alu_input_b, w_alu_result;
    wire [15:0] w_rd_data;
    
    // Flag 関連
    wire w_f_z, w_f_n, w_f_v;        // ALUからの生フラグ
    wire w_reg_f_z, w_reg_f_n, w_reg_f_v; // 保存されたフラグ
    
    // Control 関連
    wire w_jump_en;

    // ---- サブモジュールのインスタンス化 ----

    // 1. プログラムカウンタ
    program_counter u_pc (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_jump_en   (w_jump_en),
        .i_jalr_en   (w_pc_target_src),
        .i_rs1_data  (w_rs1_data),
        .i_imm       (w_imm),
        .o_pc        (w_pc),
        .o_pc_plus_2 (w_pc_plus_2)
    );

    // 2. 命令デコーダ
    instruction_decoder u_decoder (
        .i_instr         (i_instr),
        .o_rd_addr       (w_rd_addr),
        .o_rs1_addr      (w_rs1_addr),
        .o_rs2_addr      (w_rs2_addr),
        .o_reg_write     (w_reg_write),
        .o_mem_write     (w_mem_write),
        .o_mem_read      (w_mem_read),
        .o_alu_src_b     (w_alu_src_b),
        .o_alu_op        (w_alu_op),
        .o_reg_src       (w_reg_src),
        .o_pc_target_src (w_pc_target_src),
        .o_jump_uncond   (w_jump_uncond),
        .o_branch_bz     (w_branch_bz),
        .o_branch_blt    (w_branch_blt),
        .o_flag_we       (w_flag_we)
    );

    // 3. レジスタファイル
    register_file u_reg_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_rd_data),
        .i_wen      (w_reg_write),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // 4. 即値生成器
    imm_generator u_imm_gen (
        .i_instr (i_instr),
        .o_imm   (w_imm)
    );

    // 5. データパス・マルチプレクサ
    datapath_mux u_dp_mux (
        .i_alu_src_b   (w_alu_src_b),
        .i_reg_src     (w_reg_src),
        .i_rs2_data    (w_rs2_data),
        .i_imm_data    (w_imm),
        .i_alu_res     (w_alu_result),
        .i_mem_data    (i_data_from_dmem),
        .i_pc_plus_2   (w_pc_plus_2),
        .o_alu_input_b (w_alu_input_b),
        .o_rd_data     (w_rd_data)
    );

    // 6. ALU演算器
    alu_unit u_alu (
        .i_alu_op      (w_alu_op),
        .i_rs1_data    (w_rs1_data),
        .i_rs2_or_imm  (w_alu_input_b),
        .o_alu_result  (w_alu_result),
        .o_f_z         (w_f_z),
        .o_f_n         (w_f_n),
        .o_f_v         (w_f_v)
    );

    // 7. フラグレジスタ (1サイクル前の状態を保持)
    flag_register u_flag_reg (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_flag_we (w_flag_we),
        .i_z       (w_f_z),
        .i_n       (w_f_n),
        .i_v       (w_f_v),
        .o_z       (w_reg_f_z),
        .o_n       (w_reg_f_n),
        .o_v       (w_reg_f_v)
    );

    // 8. 次サイクルPC制御ロジック
    next_pc_logic u_next_pc_logic (
        .i_pc_plus_2   (w_pc_plus_2),
        .i_target_addr (16'd0), // program_counter内部で計算するため未使用
        .i_f_z         (w_reg_f_z),
        .i_f_n         (w_reg_f_n),
        .i_f_v         (w_reg_f_v),
        .i_branch_bz   (w_branch_bz),
        .i_branch_blt  (w_branch_blt),
        .i_jump_uncond (w_jump_uncond),
        .o_next_pc     (), // program_counter内部で更新するため未使用
        .o_jump_en     (w_jump_en)
    );

    // ---- 出力ポート割り当て ----
    assign o_addr_to_imem = w_pc;
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;
    assign o_dmem_wen     = w_mem_write;

    // ---- デバッグポート割り当て ----
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
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