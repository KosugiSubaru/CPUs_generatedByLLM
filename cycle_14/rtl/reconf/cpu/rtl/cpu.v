module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,           // 命令メモリからの入力
    input  wire [15:0] i_data_from_dmem,  // データメモリからの入力

    output wire [15:0] o_addr_to_dmem,    // データメモリへのアドレス
    output wire [15:0] o_data_to_dmem,    // データメモリへの書き込みデータ
    output wire [15:0] o_addr_to_imem,    // 命令メモリへのアドレス (PC)
    output wire        o_dmem_wen,        // データメモリ書き込み有効

    // デバッグ・検証用ポート
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

    // ---- 信号宣言 ----
    wire [3:0]  w_opcode  = i_instr[3:0];
    wire [3:0]  w_rd_addr = i_instr[15:12];
    wire [3:0]  w_rs1_addr = i_instr[11:8];
    wire [3:0]  w_rs2_addr = i_instr[7:4];

    wire [15:0] w_imm;
    wire [2:0]  w_imm_sel;
    wire [15:0] w_instr_active;

    wire        w_reg_wen;
    wire        w_alu_src_sel;
    wire [1:0]  w_reg_wd_sel;
    wire [3:0]  w_alu_op;
    
    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_rd_data;

    wire [15:0] w_alu_src2;
    wire [15:0] w_alu_res;
    wire        w_alu_z, w_alu_n, w_alu_v;
    wire [2:0]  w_prev_flags;
    wire        w_flag_wen;

    wire [1:0]  w_pc_sel_final;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_load_data;

    // ---- 即値生成制御論理 ----
    assign w_imm_sel = (w_opcode == 4'd8 || w_opcode == 4'd10 || w_opcode == 4'd15) ? 3'd1 :
                       (w_opcode == 4'd11) ? 3'd2 :
                       (w_opcode == 4'd9  || w_opcode == 4'd14) ? 3'd3 :
                       (w_opcode == 4'd12 || w_opcode == 4'd13) ? 3'd4 : 3'd0;

    // ---- フラグ更新制御論理 ----
    assign w_flag_wen = (w_opcode <= 4'd8);

    // ---- サブモジュール・インスタンス化 ----

    // 命令デコード (One-Hot生成)
    ctrl_unit_decoder_16 u_decoder (
        .i_opcode (w_opcode),
        .o_active (w_instr_active)
    );

    // 制御信号生成
    ctrl_unit u_ctrl (
        .i_opcode      (w_opcode),
        .i_flag_z      (w_prev_flags[0]),
        .i_flag_n      (w_prev_flags[1]),
        .i_flag_v      (w_prev_flags[2]),
        .o_reg_wen     (w_reg_wen),
        .o_dmem_wen    (o_dmem_wen),
        .o_alu_src_sel (w_alu_src_sel),
        .o_reg_wd_sel  (w_reg_wd_sel),
        .o_alu_op      (w_alu_op),
        .o_pc_sel      () // 修正：o_pc_selを空接続で追加
    );

    // 即値生成
    imm_gen u_imm_gen (
        .i_instr   (i_instr),
        .i_imm_sel (w_imm_sel),
        .o_imm     (w_imm)
    );

    // 次PCの判定
    next_pc_logic u_next_pc_eval (
        .i_now_pc       (o_addr_to_imem),
        .i_imm          (w_imm),
        .i_rs1_data     (w_rs1_data),
        .i_active_instr (w_instr_active),
        .i_flags        (w_prev_flags),
        .o_next_pc      (), // 修正：o_next_pcを空接続で追加
        .o_pc_plus_2    (w_pc_plus_2)
    );

    // 分岐条件を反映したPC選択信号を生成
    next_pc_logic_branch_eval u_branch_eval (
        .i_active (w_instr_active),
        .i_flags  (w_prev_flags),
        .o_pc_sel (w_pc_sel_final)
    );

    // PCレジスタ更新
    pc_reg u_pc_reg (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_pc_sel    (w_pc_sel_final),
        .i_imm       (w_imm),
        .i_rs1_data  (w_rs1_data),
        .o_now_pc    (o_addr_to_imem),
        .o_pc_plus_2 () 
    );

    // レジスタファイル
    reg_file u_reg_file (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_addr  (w_rd_addr),
        .i_rd_data  (w_rd_data),
        .i_reg_wen  (w_reg_wen),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    // ALUソースB選択
    assign w_alu_src2 = (w_alu_src_sel) ? w_imm : w_rs2_data;

    // ALU本体
    alu_core u_alu (
        .i_src1    (w_rs1_data),
        .i_src2    (w_alu_src2),
        .i_opcode  (w_alu_op),
        .o_res     (w_alu_res),
        .o_flag_z  (w_alu_z),
        .o_flag_n  (w_alu_n),
        .o_flag_v  (w_alu_v)
    );

    // フラグレジスタ (1クロック遅延)
    flag_reg u_flag_reg (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_flag_wen  (w_flag_wen),
        .i_flags_in  ({w_alu_v, w_alu_n, w_alu_z}),
        .o_flags_out (w_prev_flags)
    );

    // メモリ制御
    mem_ctrl u_mem_ctrl (
        .i_rs1_data        (w_rs1_data),
        .i_rs2_data        (w_rs2_data),
        .i_imm             (w_imm),
        .i_dmem_wen        (o_dmem_wen),
        .i_data_from_dmem  (i_data_from_dmem),
        .o_addr_to_dmem    (o_addr_to_dmem),
        .o_data_to_dmem    (o_data_to_dmem),
        .o_dmem_wen        (),
        .o_load_data       (w_load_data)
    );

    // レジスタ書き戻しデータ選択
    assign w_rd_data = (w_reg_wd_sel == 2'b00) ? w_alu_res :
                       (w_reg_wd_sel == 2'b01) ? w_load_data :
                       (w_reg_wd_sel == 2'b10) ? w_pc_plus_2 : 16'h0000;

    // ---- デバッグポート接続 ----
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_rd_data;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = o_addr_to_dmem;
    assign o_debug_data_to_dmem   = o_data_to_dmem;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = o_addr_to_imem;
    assign o_debug_flag_z         = w_prev_flags[0];
    assign o_debug_flag_n         = w_prev_flags[1];
    assign o_debug_flag_v         = w_prev_flags[2];

endmodule