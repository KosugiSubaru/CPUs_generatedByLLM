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
    // CPU_DEBUG_END
);

    // 内部信号定義
    wire [15:0] w_now_pc, w_next_pc, w_pc_plus_2;
    wire [15:0] w_rs1_data, w_rs2_data, w_rd_data;
    wire [15:0] w_imm, w_alu_result, w_wb_data_tmp;
    wire [3:0]  w_alu_op;
    wire [1:0]  w_imm_sel;
    wire        w_reg_wen, w_alu_src_sel, w_mem_to_reg;
    wire        w_pc_src_sel, w_pc_base_sel, w_reg_data_sel;
    wire        w_alu_z, w_alu_n, w_alu_v;
    wire        w_flag_z, w_flag_n, w_flag_v;

    // 1. プログラムカウンタ (PC)
    pc_reg u_pc_reg (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_next_pc (w_next_pc),
        .o_now_pc  (w_now_pc)
    );
    assign o_addr_to_imem = w_now_pc;

    // 2. コントロールユニット
    control_unit u_control_unit (
        .i_instr        (i_instr),
        .i_flag_z       (w_flag_z),
        .i_flag_n       (w_flag_n),
        .i_flag_v       (w_flag_v),
        .o_reg_file_wen (w_reg_wen),
        .o_alu_op       (w_alu_op),
        .o_alu_src_sel  (w_alu_src_sel),
        .o_dmem_wen     (o_dmem_wen),
        .o_mem_to_reg   (w_mem_to_reg),
        .o_pc_src_sel   (w_pc_src_sel),
        .o_pc_base_sel  (w_pc_base_sel),
        .o_reg_data_sel (w_reg_data_sel)
    );

    // 即値選択ロジック (opcodeから抽出)
    assign w_imm_sel[0] = (i_instr[3:0] == 4'b1011) || (i_instr[3:0] == 4'b1100) || (i_instr[3:0] == 4'b1101);
    assign w_imm_sel[1] = (i_instr[3:0] == 4'b1001) || (i_instr[3:0] == 4'b1110) || (i_instr[3:0] == 4'b1100) || (i_instr[3:0] == 4'b1101);

    // 3. レジスタファイル
    register_file u_register_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (i_instr[11:8]),
        .i_rs2_addr (i_instr[7:4]),
        .i_rd_addr  (i_instr[15:12]),
        .i_rd_data  (w_rd_data),
        .i_wen      (w_reg_wen),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // 4. 即値拡張器
    imm_extender u_imm_extender (
        .i_instr   (i_instr),
        .i_imm_sel (w_imm_sel),
        .o_imm     (w_imm)
    );

    // 5. ALU
    alu u_alu (
        .i_a        (w_rs1_data),
        .i_b        (w_alu_src_sel ? w_imm : w_rs2_data),
        .i_alu_op   (w_alu_op),
        .o_result   (w_alu_result),
        .o_flag_z   (w_alu_z),
        .o_flag_n   (w_alu_n),
        .o_flag_v   (w_alu_v)
    );

    // 6. フラグレジスタ (1クロック遅延)
    flag_reg u_flag_reg (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_alu_z  (w_alu_z),
        .i_alu_n  (w_alu_n),
        .i_alu_v  (w_alu_v),
        .o_flag_z (w_flag_z),
        .o_flag_n (w_flag_n),
        .o_flag_v (w_flag_v)
    );

    // 7. PC計算・選択ロジック
    pc_logic u_pc_logic (
        .i_now_pc      (w_now_pc),
        .i_rs1_data    (w_rs1_data),
        .i_imm         (w_imm),
        .i_pc_src_sel  (w_pc_src_sel),
        .i_pc_base_sel (w_pc_base_sel),
        .o_next_pc     (w_next_pc),
        .o_pc_plus_2   (w_pc_plus_2)
    );

    // データメモリへの出力
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;

    // 書き戻しデータ選択
    assign w_wb_data_tmp = (w_mem_to_reg) ? i_data_from_dmem : w_alu_result;
    assign w_rd_data     = (w_reg_data_sel) ? w_pc_plus_2 : w_wb_data_tmp;

    // デバッグ出力の接続
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = i_instr[11:8];
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = i_instr[7:4];
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = i_instr[15:12];
    assign o_debug_rd_data        = w_rd_data;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_now_pc;
    assign o_debug_flag_z         = w_flag_z;
    assign o_debug_flag_n         = w_flag_n;
    assign o_debug_flag_v         = w_flag_v;

endmodule