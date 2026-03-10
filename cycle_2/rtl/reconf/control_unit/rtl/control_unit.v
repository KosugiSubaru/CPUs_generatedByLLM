module control_unit (
    input  wire [3:0]  i_opcode,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire        o_reg_write,
    output wire        o_mem_write,
    output wire        o_alu_src,      // 0: rs2_data, 1: imm
    output wire [1:0]  o_reg_res_sel,  // 0: ALU, 1: Mem, 2: PC+2, 3: Imm
    output wire [3:0]  o_alu_op,
    output wire [2:0]  o_imm_type,     // 即値抽出形式の切り替え
    output wire [1:0]  o_pc_sel        // 00: PC+2, 01: PC+imm, 10: rs1+imm, 11: reset
);

    // 内部信号：16本の命令有効信号 (1-hot)
    wire [15:0] w_inst_vector;

    // --- 1. 命令デコード部 (Decoder) ---
    // opcode[3:0]を解析し、どの命令が有効かを判定
    control_unit_decoder_4to16 u_decoder (
        .i_opcode (i_opcode),
        .o_inst   (w_inst_vector)
    );

    // --- 2. 制御信号マッピング部 (Signal Map) ---
    // 有効な命令信号の組み合わせから、データパスの各セレクタ・許可信号を生成
    control_unit_signal_map u_signal_map (
        .i_inst        (w_inst_vector),
        .o_reg_write   (o_reg_write),
        .o_mem_write   (o_mem_write),
        .o_alu_src     (o_alu_src),
        .o_reg_res_sel (o_reg_res_sel),
        .o_alu_op      (o_alu_op),
        .o_imm_type    (o_imm_type)
    );

    // --- 3. 分岐判定部 (Branch Condition) ---
    // フラグの状態と命令の種類に基づき、次に進むべきPCの選択信号を生成
    control_unit_branch_cond u_branch_cond (
        .i_inst   (w_inst_vector),
        .i_flag_z (i_flag_z),
        .i_flag_n (i_flag_n),
        .i_flag_v (i_flag_v),
        .o_pc_sel (o_pc_sel)
    );

endmodule