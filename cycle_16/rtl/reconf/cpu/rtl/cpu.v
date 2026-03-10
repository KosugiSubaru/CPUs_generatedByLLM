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
    wire [15:0] w_next_pc;
    wire [15:0] w_pc_plus_2;
    wire [3:0]  w_rs1_addr, w_rs2_addr, w_rd_addr;
    wire [15:0] w_rs1_data, w_rs2_data;
    wire [15:0] w_imm;
    wire [3:0]  w_alu_op;
    wire        w_reg_wen, w_dmem_wen, w_alu_src_b_sel;
    wire [1:0]  w_pc_sel, w_reg_wdata_sel;
    wire [15:0] w_alu_result, w_alu_in_b, w_reg_wdata;
    wire        w_alu_f_z, w_alu_f_n, w_alu_f_v;
    wire        w_stored_f_z, w_stored_f_n, w_stored_f_v;
    wire [1:0]  w_imm_sel;

    // 即値選択ロジック（Opcodeに基づき即値形式を決定）
    assign w_imm_sel = (i_instr[3:0] == 4'b1000 || i_instr[3:0] == 4'b1010 || i_instr[3:0] == 4'b1111) ? 2'b00 : // Type A
                       (i_instr[3:0] == 4'b1001 || i_instr[3:0] == 4'b1110) ? 2'b01 : // Type B
                       (i_instr[3:0] == 4'b1011) ? 2'b10 : // Type C
                       2'b11; // Type D (Branch)

    // PC ユニット (PCレジスタ保持)
    pc_unit_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_data  (w_next_pc),
        .o_pc    (w_pc)
    );

    // 次PCロジック (アドレス計算と選択)
    next_pc_logic u_next_pc_logic (
        .i_pc       (w_pc),
        .i_imm      (w_imm),
        .i_rs1_data (w_rs1_data),
        .i_pc_sel   (w_pc_sel),
        .o_next_pc  (w_next_pc)
    );

    // 命令デコーダー
    instruction_decoder u_decoder (
        .i_instr         (i_instr),
        .i_flag_z        (w_stored_f_z),
        .i_flag_n        (w_stored_f_n),
        .i_flag_v        (w_stored_f_v),
        .o_rs1_addr      (w_rs1_addr),
        .o_rs2_addr      (w_rs2_addr),
        .o_rd_addr       (w_rd_addr),
        .o_alu_op        (w_alu_op),
        .o_reg_wen       (w_reg_wen),
        .o_dmem_wen      (w_dmem_wen),
        .o_pc_sel        (w_pc_sel),
        .o_alu_src_b_sel (w_alu_src_b_sel),
        .o_reg_wdata_sel (w_reg_wdata_sel)
    );

    // 即値生成器
    immediate_generator u_imm_gen (
        .i_instr   (i_instr),
        .i_imm_sel (w_imm_sel),
        .o_imm     (w_imm)
    );

    // レジスタファイル
    register_file u_reg_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_reg_wdata),
        .i_rd_wen   (w_reg_wen),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // ALU 入力B セレクタ
    assign w_alu_in_b = (w_alu_src_b_sel) ? w_imm : w_rs2_data;

    // ALU 
    alu_core u_alu (
        .i_alu_op (w_alu_op),
        .i_data_a (w_rs1_data),
        .i_data_b (w_alu_in_b),
        .o_result (w_alu_result),
        .o_flag_z (w_alu_f_z),
        .o_flag_n (w_alu_f_n),
        .o_flag_v (w_alu_f_v)
    );

    // フラグレジスタ (1クロック遅延)
    flag_register u_flag_reg (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_alu_z  (w_alu_f_z),
        .i_alu_n  (w_alu_f_n),
        .i_alu_v  (w_alu_f_v),
        .o_flag_z (w_stored_f_z),
        .o_flag_n (w_stored_f_n),
        .o_flag_v (w_stored_f_v)
    );

    // PC+2 計算 (書き戻しMUX用)
    assign w_pc_plus_2 = w_pc + 16'h0002;

    // 書き戻しマルチプレクサ
    writeback_mux u_wb_mux (
        .i_sel        (w_reg_wdata_sel),
        .i_alu_result (w_alu_result),
        .i_dmem_data  (i_data_from_dmem),
        .i_pc_plus_2  (w_pc_plus_2),
        .i_imm_data   (w_imm),
        .o_wdata      (w_reg_wdata)
    );

    // 外部出力ポート接続
    assign o_addr_to_imem   = w_pc;
    assign o_addr_to_dmem   = w_alu_result;
    assign o_data_to_dmem   = w_rs2_data;
    assign o_dmem_wen       = w_dmem_wen;

    // Debug ポート接続
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_reg_wdata;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = w_dmem_wen;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc;
    assign o_debug_flag_z         = w_stored_f_z;
    assign o_debug_flag_n         = w_stored_f_n;
    assign o_debug_flag_v         = w_stored_f_v;

endmodule