module next_pc_logic (
    input  wire [15:0] i_pc,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire [3:0]  i_opcode,      // 分岐判定用にOpcode入力を追加
    input  wire [1:0]  i_pc_sel,      // 00:PC+2, 01:PC+imm, 10:rs1+imm, 11:PC(Hold)
    input  wire        i_flag_z,      // 1クロック前のZフラグ
    input  wire        i_flag_n,      // 1クロック前のNフラグ
    input  wire        i_flag_v,      // 1クロック前のVフラグ
    output wire [15:0] o_next_pc
);

    wire [15:0] w_pc_candidates [2:0]; 
    wire        w_branch_taken;

    // 計算ユニット：次サイクルのPC候補となるアドレスを並列に算出
    next_pc_logic_calc_unit u_calc (
        .i_pc           (i_pc),
        .i_imm          (i_imm),
        .i_rs1_data     (i_rs1_data),
        .o_pc_plus_2    (w_pc_candidates[0]),
        .o_pc_plus_imm  (w_pc_candidates[1]),
        .o_rs1_plus_imm (w_pc_candidates[2])
    );

    // 分岐判定ユニット：Opcodeとフラグを接続
    next_pc_logic_branch_eval u_eval (
        .i_opcode (i_opcode), // ポート欠落エラーを修正
        .i_flag_z (i_flag_z),
        .i_flag_n (i_flag_n),
        .i_flag_v (i_flag_v),
        .o_taken  (w_branch_taken)
    );

    // 4to1セレクタ：制御信号に基づき次アドレスを選択
    next_pc_logic_mux_4to1_16bit u_mux (
        .i_sel  (i_pc_sel),
        .i_d0   (w_pc_candidates[0]), 
        .i_d1   (w_pc_candidates[1]), 
        .i_d2   (w_pc_candidates[2]), 
        .i_d3   (i_pc),               
        .o_data (o_next_pc)
    );

endmodule