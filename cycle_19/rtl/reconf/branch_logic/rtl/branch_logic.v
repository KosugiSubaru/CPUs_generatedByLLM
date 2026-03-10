module branch_logic (
    input  wire [3:0]  i_opcode,         // 命令オペコード
    input  wire        i_flag_z,         // 前クロックのゼロフラグ
    input  wire        i_flag_n,         // 前クロックのネガティブフラグ
    input  wire        i_flag_v,         // 前クロックのオーバーフローフラグ
    input  wire        i_is_branch,      // 分岐命令フラグ
    input  wire        i_is_jump,        // ジャンプ命令フラグ
    input  wire        i_is_jalr,        // JALR命令フラグ
    input  wire [15:0] i_pc_plus_2,      // 通常進捗用PC+2
    input  wire [15:0] i_pc_plus_imm,    // 分岐・JAL用ターゲットアドレス
    input  wire [15:0] i_rs1_plus_imm,   // JALR用ターゲットアドレス
    output wire [15:0] o_next_pc         // 最終的な次PC選択結果
);

    wire       w_cond_met;
    wire [1:0] w_sel;

    // 条件判定ユニットのインスタンス化
    generate
        branch_logic_cond u_cond (
            .i_opcode   (i_opcode),
            .i_flag_z   (i_flag_z),
            .i_flag_n   (i_flag_n),
            .i_flag_v   (i_flag_v),
            .o_cond_met (w_cond_met)
        );
    endgenerate

    // 選択信号の生成論理
    // sel[1]: JALR命令時に1 (10を選択)
    // sel[0]: JAL命令、または条件が成立した分岐命令時に1 (01を選択)
    assign w_sel[1] = i_is_jalr;
    assign w_sel[0] = (i_is_jump && !i_is_jalr) || (i_is_branch && w_cond_met);

    // アドレス選択マルチプレクサのインスタンス化
    generate
        branch_logic_mux u_mux (
            .i_sel          (w_sel),
            .i_pc_plus_2    (i_pc_plus_2),
            .i_pc_plus_imm  (i_pc_plus_imm),
            .i_rs1_plus_imm (i_rs1_plus_imm),
            .o_next_pc      (o_next_pc)
        );
    endgenerate

endmodule