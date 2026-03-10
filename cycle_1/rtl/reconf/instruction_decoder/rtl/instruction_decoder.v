module instruction_decoder (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire [11:0] o_imm_raw,
    output wire [3:0]  o_alu_op,
    output wire        o_reg_wen,
    output wire        o_mem_wen,
    output wire        o_alu_src_b_imm,
    output wire [1:0]  o_reg_data_sel,
    output wire        o_branch_blt,
    output wire        o_branch_bz,
    output wire        o_jump_jal,
    output wire        o_jump_jalr
);

    wire [3:0]  w_opcode;
    wire [15:0] w_instr_signals;
    wire        w_unused_mem_to_reg;

    // 1. 命令フィールドの抽出
    // ビット位置に基づき、物理的にワイヤを分離して各フィールドを取り出す
    instruction_decoder_field_extractor u_extractor (
        .i_instr    (i_instr),
        .o_opcode   (w_opcode),
        .o_rd_addr  (o_rd_addr),
        .o_rs1_addr (o_rs1_addr),
        .o_rs2_addr (o_rs2_addr),
        .o_imm_raw  (o_imm_raw)
    );

    // 2. 命令デコードバスの生成
    // オペコードを解析し、16本の個別命令信号（is_add等）へ展開
    instruction_decoder_op_bus u_op_bus (
        .i_opcode        (w_opcode),
        .o_instr_signals (w_instr_signals)
    );

    // 3. 制御ロジックの生成
    // 展開された命令信号を束ね、CPU各部への制御信号を論理合成
    instruction_decoder_control_logic u_control (
        .i_instr_signals (w_instr_signals),
        .o_reg_wen       (o_reg_wen),
        .o_mem_wen       (o_mem_wen),
        .o_mem_to_reg    (w_unused_mem_to_reg),
        .o_alu_src_b_imm (o_alu_src_b_imm),
        .o_reg_data_sel  (o_reg_data_sel),
        .o_branch_blt    (o_branch_blt),
        .o_branch_bz     (o_branch_bz),
        .o_jump_jal      (o_jump_jal),
        .o_jump_jalr     (o_jump_jalr)
    );

    // ALUオペコードの出力
    // 本ISAでは命令のオペコードがそのままALUの演算種別にマッピングされている
    assign o_alu_op = w_opcode;

endmodule