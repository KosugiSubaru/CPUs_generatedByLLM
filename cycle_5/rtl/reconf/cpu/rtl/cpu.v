module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,          // imemからの命令
    input  wire [15:0] i_data_from_dmem, // dmemからの読み出しデータ

    output wire [15:0] o_addr_to_dmem,   // dmemへのアドレス
    output wire [15:0] o_data_to_dmem,   // dmemへの書き込みデータ
    output wire [15:0] o_addr_to_imem,   // imemへのアドレス (PC)
    output wire        o_dmem_wen,       // dmemへの書き込み有効信号

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

    // 内部接続用ワイヤ
    wire [15:0] w_pc;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_imm;
    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_rd_data_wb;
    wire [15:0] w_alu_src2;
    wire [15:0] w_alu_result;

    // 制御信号
    wire [3:0]  w_alu_mode;
    wire        w_reg_wen;
    wire        w_dmem_wen;
    wire [1:0]  w_reg_src_sel;
    wire        w_alu_src_sel;
    wire [1:0]  w_pc_sel;
    wire        w_flag_wen;

    // フラグレジスタ出力 (1クロック前の状態)
    wire w_flag_z_reg;
    wire w_flag_n_reg;
    wire w_flag_v_reg;

    // ALUからの現在のフラグ
    wire w_flag_z_alu;
    wire w_flag_n_alu;
    wire w_flag_v_alu;

    // -------------------------------------------------------------------------
    // 1. プログラムカウンタ (PC)
    // -------------------------------------------------------------------------
    program_counter u_pc (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_pc_sel       (w_pc_sel),
        .i_imm          (w_imm),
        .i_rs1_data     (w_rs1_data),
        .o_pc           (w_pc),
        .o_pc_plus_2    (w_pc_plus_2)
    );

    // -------------------------------------------------------------------------
    // 2. 制御ユニット (Control Unit)
    // -------------------------------------------------------------------------
    control_unit u_control_unit (
        .i_opcode      (i_instr[3:0]),
        .i_flag_z      (w_flag_z_reg),
        .i_flag_n      (w_flag_n_reg),
        .i_flag_v      (w_flag_v_reg),
        .o_alu_mode    (w_alu_mode),
        .o_reg_wen     (w_reg_wen),
        .o_dmem_wen    (w_dmem_wen),
        .o_reg_src_sel (w_reg_src_sel),
        .o_alu_src_sel (w_alu_src_sel),
        .o_pc_sel      (w_pc_sel)
    );

    // -------------------------------------------------------------------------
    // 3. レジスタファイル (Register File)
    // -------------------------------------------------------------------------
    register_file u_register_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_reg_wen  (w_reg_wen),
        .i_rd_addr  (i_instr[15:12]),
        .i_rd_data  (w_rd_data_wb),
        .i_rs1_addr (i_instr[11:8]),
        .i_rs2_addr (i_instr[7:4]),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // -------------------------------------------------------------------------
    // 4. 即値生成器 (Immediate Generator)
    // -------------------------------------------------------------------------
    imm_gen u_imm_gen (
        .i_instr (i_instr),
        .o_imm   (w_imm)
    );

    // -------------------------------------------------------------------------
    // 5. ALU (Arithmetic Logic Unit)
    // -------------------------------------------------------------------------
    assign w_alu_src2 = (w_alu_src_sel == 1'b0) ? w_rs2_data : w_imm;

    alu u_alu (
        .i_alu_mode (w_alu_mode),
        .i_src1     (w_rs1_data),
        .i_src2     (w_alu_src2),
        .o_result   (w_alu_result),
        .o_flag_z   (w_flag_z_alu),
        .o_flag_n   (w_flag_n_alu),
        .o_flag_v   (w_flag_v_alu)
    );

    // -------------------------------------------------------------------------
    // 6. フラグレジスタ (Flag Register)
    // -------------------------------------------------------------------------
    // 算術演算命令(add:0000, sub:0001, addi:1000)のみフラグを更新
    assign w_flag_wen = (i_instr[3:0] == 4'b0000) || 
                        (i_instr[3:0] == 4'b0001) || 
                        (i_instr[3:0] == 4'b1000);

    flag_register u_flag_register (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_wen    (w_flag_wen),
        .i_alu_z  (w_flag_z_alu),
        .i_alu_n  (w_flag_n_alu),
        .i_alu_v  (w_flag_v_alu),
        .o_flag_z (w_flag_z_reg),
        .o_flag_n (w_flag_n_reg),
        .o_flag_v (w_flag_v_reg)
    );

    // -------------------------------------------------------------------------
    // 7. データ書き戻し選択 (Write Back Select)
    // -------------------------------------------------------------------------
    assign w_rd_data_wb = (w_reg_src_sel == 2'b00) ? w_alu_result :
                         (w_reg_src_sel == 2'b01) ? i_data_from_dmem :
                         (w_reg_src_sel == 2'b10) ? w_imm :
                                                    w_pc_plus_2;

    // -------------------------------------------------------------------------
    // 出力ポート接続
    // -------------------------------------------------------------------------
    assign o_addr_to_imem = w_pc;
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;
    assign o_dmem_wen     = w_dmem_wen;

    // デバッグ出力
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = i_instr[11:8];
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = i_instr[7:4];
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = i_instr[15:12];
    assign o_debug_rd_data        = w_rd_data_wb;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = w_dmem_wen;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc;
    assign o_debug_flag_n         = w_flag_n_reg;
    assign o_debug_flag_v         = w_flag_v_reg;
    assign o_debug_flag_z         = w_flag_z_reg;

endmodule