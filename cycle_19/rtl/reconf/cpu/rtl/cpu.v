module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,
    input  wire [15:0] i_data_from_dmem,

    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire [15:0] o_addr_to_imem,
    output wire        o_dmem_wen,

    // デバッグ用出力
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
    wire [15:0] w_now_pc;
    wire [15:0] w_next_pc;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_imm;
    wire [15:0] w_alu_b;
    wire [15:0] w_alu_res;
    wire [15:0] w_wb_data;
    
    // 制御信号
    wire [3:0]  w_rd_addr, w_rs1_addr, w_rs2_addr;
    wire        w_reg_wen, w_dmem_wen, w_mem_to_reg, w_alu_src;
    wire [3:0]  w_alu_op;
    wire        w_is_branch, w_is_jump, w_is_jalr;

    // フラグ信号
    wire w_flag_z, w_flag_n, w_flag_v;
    wire w_stored_z, w_stored_n, w_stored_v;

    // --- 1. プログラムカウンタ (Fetch) ---
    pc_reg u_pc_reg (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_next_pc (w_next_pc),
        .o_pc      (w_now_pc)
    );

    assign o_addr_to_imem = w_now_pc;

    pc_adder u_pc_inc (
        .i_a   (w_now_pc),
        .i_b   (16'h0002),
        .o_sum (w_pc_plus_2)
    );

    // --- 2. デコーダ & 即値生成 (Decode) ---
    instruction_decoder u_decoder (
        .i_instr      (i_instr),
        .o_rd         (w_rd_addr),
        .o_rs1        (w_rs1_addr),
        .o_rs2        (w_rs2_addr),
        .o_imm        (w_imm),
        .o_reg_wen    (w_reg_wen),
        .o_dmem_wen   (w_dmem_wen),
        .o_mem_to_reg (w_mem_to_reg),
        .o_alu_src    (w_alu_src),
        .o_alu_op     (w_alu_op),
        .o_is_branch  (w_is_branch),
        .o_is_jump    (w_is_jump),
        .o_is_jalr    (w_is_jalr)
    );

    // --- 3. レジスタファイル ---
    reg_file u_reg_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_wen      (w_reg_wen),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_wb_data),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // --- 4. 実行ユニット (Execute) ---
    alu_src_mux u_alu_src_mux (
        .i_sel  (w_alu_src),
        .i_rs2  (w_rs2_data),
        .i_imm  (w_imm),
        .o_data (w_alu_b)
    );

    alu u_alu (
        .i_a      (w_rs1_data),
        .i_b      (w_alu_b),
        .i_imm    (w_imm),
        .i_alu_op (w_alu_op),
        .o_res    (w_alu_res),
        .o_flag_z (w_flag_z),
        .o_flag_n (w_flag_n),
        .o_flag_v (w_flag_v)
    );

    // フラグレジスタ (1クロック遅延)
    flag_reg u_flag_reg (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_alu_flag_z (w_flag_z),
        .i_alu_flag_n (w_flag_n),
        .i_alu_flag_v (w_flag_v),
        .o_flag_z     (w_stored_z),
        .o_flag_n     (w_stored_n),
        .o_flag_v     (w_stored_v)
    );

    // --- 5. メモリアクセス (Memory) ---
    assign o_addr_to_dmem = w_alu_res;
    assign o_data_to_dmem = w_rs2_data;
    assign o_dmem_wen     = w_dmem_wen;

    // --- 6. 書き戻し (Write-back) ---
    writeback_mux u_wb_mux (
        .i_mem_to_reg (w_mem_to_reg),
        .i_is_jump    (w_is_jump),
        .i_alu_res    (w_alu_res),
        .i_mem_res    (i_data_from_dmem),
        .i_pc_plus_2  (w_pc_plus_2),
        .o_write_data (w_wb_data)
    );

    // --- 7. 次PC決定 (Branch/Jump Logic) ---
    branch_logic u_branch_logic (
        .i_opcode       (i_instr[3:0]),
        .i_flag_z       (w_stored_z),
        .i_flag_n       (w_stored_n),
        .i_flag_v       (w_stored_v),
        .i_is_branch    (w_is_branch),
        .i_is_jump      (w_is_jump),
        .i_is_jalr      (w_is_jalr),
        .i_pc_plus_2    (w_pc_plus_2),
        .i_pc_plus_imm  (w_now_pc + w_imm),
        .i_rs1_plus_imm (w_rs1_data + w_imm),
        .o_next_pc      (w_next_pc)
    );

    // --- デバッグ信号の接続 ---
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_wb_data;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = w_dmem_wen;
    assign o_debug_adder_to_dmem  = w_alu_res;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_now_pc;
    assign o_debug_flag_n         = w_stored_n;
    assign o_debug_flag_v         = w_stored_v;
    assign o_debug_flag_z         = w_stored_z;

endmodule