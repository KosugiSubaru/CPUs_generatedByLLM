module next_pc_logic (
    input  wire [15:0] i_now_pc,        // 現在のPC値
    input  wire [15:0] i_imm,           // 符号拡張済み即値
    input  wire [15:0] i_rs1_data,      // rs1レジスタの値 (jalr用)
    input  wire [15:0] i_active_instr,  // デコーダからのOne-Hot命令信号
    input  wire [2:0]  i_flags,         // 保持されているフラグ [2]:V, [1]:N, [0]:Z
    output wire [15:0] o_next_pc,       // 次のサイクルでPCレジスタに書く値
    output wire [15:0] o_pc_plus_2      // rdに書き込む戻り先アドレス (jal/jalr用)
);

    // 内部信号
    wire [1:0]  w_pc_sel;
    wire [15:0] w_addr_pc2;
    wire [15:0] w_addr_imm;
    wire [15:0] w_addr_reg;

    // 階層1: 分岐条件の評価
    // フラグと命令種別を照合し、遷移先を選択する信号（w_pc_sel）を生成
    next_pc_logic_branch_eval u_eval (
        .i_active (i_active_instr),
        .i_flags  (i_flags),
        .o_pc_sel (w_pc_sel)
    );

    // 階層1: 各ターゲットアドレスの計算
    // パタン構造化のため、3つの加算器を論理的に分離して配置
    
    // 通常増分 (PC + 2)
    next_pc_logic_adder_16bit u_adder_inc (
        .i_a   (i_now_pc),
        .i_b   (16'h0002),
        .o_sum (w_addr_pc2)
    );

    // 相対ジャンプ (PC + imm)
    next_pc_logic_adder_16bit u_adder_rel (
        .i_a   (i_now_pc),
        .i_b   (i_imm),
        .o_sum (w_addr_imm)
    );

    // レジスタ間接ジャンプ (rs1 + imm)
    next_pc_logic_adder_16bit u_adder_ind (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_addr_reg)
    );

    // 階層1: 最終的な次PC値の選択
    // 00: PC+2, 01: PC+imm, 10: rs1+imm
    next_pc_logic_mux3_16bit u_mux (
        .i_sel (w_pc_sel),
        .i_d0  (w_addr_pc2),
        .i_d1  (w_addr_imm),
        .i_d2  (w_addr_reg),
        .o_q   (o_next_pc)
    );

    // jal/jalr命令でrdに保存する値を定義
    assign o_pc_plus_2 = w_addr_pc2;

endmodule