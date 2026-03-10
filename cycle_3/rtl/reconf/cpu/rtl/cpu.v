module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,
    input  wire [15:0] i_data_from_dmem,

    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire [15:0] o_addr_to_imem,
    output wire        o_dmem_wen,

    // CPU_DEBUG_PORTS
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

    // 内部制御信号
    wire        w_reg_write;
    wire        w_mem_write;
    wire        w_mem_to_reg;
    wire        w_alu_src;
    wire        w_reg_data_sel;
    wire [3:0]  w_alu_op;

    // データパス信号
    wire [15:0] w_pc;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_rd_data;
    wire [15:0] w_imm;
    wire [15:0] w_alu_b;
    wire [15:0] w_alu_result;
    wire [15:0] w_reg_wb_data;

    // フラグ信号
    wire        w_alu_z;
    wire        w_alu_n;
    wire        w_alu_v;
    wire        w_held_z;
    wire        w_held_n;
    wire        w_held_v;

    // プログラムカウンタ・ユニット (PC保持および次PC計算)
    program_counter u_pc_unit (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_opcode     (i_instr[3:0]),
        .i_flag_z     (w_held_z),
        .i_flag_n     (w_held_n),
        .i_flag_v     (w_held_v),
        .i_imm        (w_imm),
        .i_rs1_data   (w_rs1_data),
        .o_pc         (w_pc),
        .o_pc_plus_2  (w_pc_plus_2)
    );

    // 制御ユニット (命令デコード)
    control_unit u_ctrl_unit (
        .i_opcode      (i_instr[3:0]),
        .o_reg_write   (w_reg_write),
        .o_mem_write   (w_mem_write),
        .o_mem_to_reg  (w_mem_to_reg),
        .o_alu_src     (w_alu_src),
        .o_reg_data_sel(w_reg_data_sel),
        .o_alu_op      (w_alu_op)
    );

    // レジスタファイル
    register_file u_reg_file (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_wen       (w_reg_write),
        .i_rs1_addr  (i_instr[11:8]),
        .i_rs2_addr  (i_instr[7:4]),
        .i_rd_addr   (i_instr[15:12]),
        .i_rd_data   (w_rd_data),
        .o_rs1_data  (w_rs1_data),
        .o_rs2_data  (w_rs2_data)
    );

    // 即値生成器
    imm_gen u_imm_gen (
        .i_instr (i_instr),
        .o_imm   (w_imm)
    );

    // ALU入力Bセレクタ
    assign w_alu_b = (w_alu_src) ? w_imm : w_rs2_data;

    // ALU (算術論理演算)
    alu u_alu (
        .i_rs1_data (w_rs1_data),
        .i_rs2_data (w_alu_b),
        .i_alu_op   (w_alu_op),
        .o_result   (w_alu_result),
        .o_flag_z   (w_alu_z),
        .o_flag_n   (w_alu_n),
        .o_flag_v   (w_alu_v)
    );

    // フラグレジスタ (1クロック遅延)
    flag_reg u_flag_reg (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_opcode (i_instr[3:0]),
        .i_alu_z  (w_alu_z),
        .i_alu_n  (w_alu_n),
        .i_alu_v  (w_alu_v),
        .o_flag_z (w_held_z),
        .o_flag_n (w_held_n),
        .o_flag_v (w_held_v)
    );

    // レジスタ書き戻しデータ・セレクタ
    // ALU結果かメモリ読み出しデータかを選択
    assign w_reg_wb_data = (w_mem_to_reg) ? i_data_from_dmem : w_alu_result;
    // 通常結果かPC+2(JAL/JALR用)かを選択
    assign w_rd_data     = (w_reg_data_sel) ? w_pc_plus_2 : w_reg_wb_data;

    // 外部メモリインターフェース接続
    assign o_addr_to_imem = w_pc;
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;
    assign o_dmem_wen     = w_mem_write;

    // デバッグポート接続
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
    assign o_debug_flag_n         = w_held_n;
    assign o_debug_flag_v         = w_held_v;
    assign o_debug_flag_z         = w_held_z;

endmodule