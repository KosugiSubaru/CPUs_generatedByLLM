module pc_control_logic (
    input  wire [3:0] i_opcode,   // 命令デコーダからのオペコード
    input  wire       i_flag_z,   // フラグレジスタからのZeroフラグ
    input  wire       i_flag_n,   // フラグレジスタからのNegativeフラグ
    input  wire       i_flag_v,   // フラグレジスタからのOverflowフラグ
    output wire [1:0] o_pc_sel    // PCユニットへの選択信号 (00:PC+2, 01:Target_PC, 10:Target_RS1)
);

    // 内部接続用ワイヤ
    wire w_branch_taken;
    wire w_jal_en;
    wire w_jalr_en;

    // 命令の特定（回路図上での識別性を高めるための論理割当）
    assign w_jal_en  = (i_opcode == 4'b1110); // JAL命令有効
    assign w_jalr_en = (i_opcode == 4'b1111); // JALR命令有効

    // --- 1. 条件判定階層 (Branch Condition) ---
    // BLT(1100)やBZ(1101)などの条件分岐命令が成立しているか判定
    // 内部で各条件チェッカーを並列に配置
    pc_control_logic_branch_array u_branch_array (
        .i_opcode (i_opcode),
        .i_flag_z (i_flag_z),
        .i_flag_n (i_flag_n),
        .i_flag_v (i_flag_v),
        .o_taken  (w_branch_taken)
    );

    // --- 2. 選択信号生成階層 (Source Decoder) ---
    // 分岐成立信号とジャンプ命令信号を統合し、最終的なPCソースを決定
    // 00: PC + 2
    // 01: PC + Imm (Branch Taken または JAL)
    // 10: rs1 + Imm (JALR)
    pc_control_logic_source_dec u_source_dec (
        .i_branch_taken (w_branch_taken),
        .i_jal_en       (w_jal_en),
        .i_jalr_en      (w_jalr_en),
        .o_pc_sel       (o_pc_sel)
    );

endmodule