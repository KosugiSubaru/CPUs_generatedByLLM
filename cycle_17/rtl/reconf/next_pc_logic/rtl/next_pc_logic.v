module next_pc_logic (
    input  wire [15:0] i_pc_plus_2,   // デフォルトの次アドレス (PC+2)
    input  wire [15:0] i_target_addr, // 分岐・ジャンプ先の計算済みアドレス
    input  wire        i_f_z,         // フラグレジスタからのZフラグ
    input  wire        i_f_n,         // フラグレジスタからのNフラグ
    input  wire        i_f_v,         // フラグレジスタからのVフラグ
    input  wire        i_branch_bz,   // デコーダからのBZ命令フラグ
    input  wire        i_branch_blt,  // デコーダからのBLT命令フラグ
    input  wire        i_jump_uncond, // デコーダからの無条件ジャンプフラグ (jal, jalr)
    output wire [15:0] o_next_pc,     // 最終的に選択された次サイクルPC
    output wire        o_jump_en      // ジャンプ実行信号（デバッグ用）
);

    wire w_cond_met;
    wire w_final_jump_en;

    // 1. 分岐条件の判定 (bz:Z, blt:N^V)
    next_pc_logic_condition u_cond_eval (
        .i_f_z        (i_f_z),
        .i_f_n        (i_f_n),
        .i_f_v        (i_f_v),
        .i_branch_bz  (i_branch_bz),
        .i_branch_blt (i_branch_blt),
        .o_cond_met   (w_cond_met)
    );

    // 2. 最終的なジャンプ実行判断 (無条件ジャンプ OR 条件成立)
    assign w_final_jump_en = i_jump_uncond | w_cond_met;

    // 3. 次サイクルPCの選択 (0: PC+2, 1: Target Address)
    next_pc_logic_mux2_16bit u_mux_pc_select (
        .i_sel (w_final_jump_en),
        .i_d0  (i_pc_plus_2),
        .i_d1  (i_target_addr),
        .o_y   (o_next_pc)
    );

    assign o_jump_en = w_final_jump_en;

endmodule