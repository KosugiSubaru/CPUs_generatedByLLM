module next_pc_logic (
    input  wire [15:0] i_current_pc,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire [1:0]  i_pc_sel_from_cu, // 00:Normal, 01:Branch, 10:JAL, 11:JALR
    input  wire        i_is_blt,         // blt命令であるか
    input  wire        i_is_bz,          // bz命令であるか
    input  wire        i_flag_z,         // 前クロックのZフラグ
    input  wire        i_flag_n,         // 前クロックのNフラグ
    input  wire        i_flag_v,         // 前クロックのVフラグ
    output wire [15:0] o_next_pc,
    output wire [15:0] o_pc_plus_2
);

    // 内部ワイヤ
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_pc_target;
    wire [15:0] w_jalr_target;
    wire [1:0]  w_final_sel;
    wire        w_branch_taken;
    wire        w_dummy_cout1, w_dummy_cout2, w_dummy_cout3;

    // 1. 通常進捗アドレスの計算 (PC + 2)
    next_pc_logic_adder_16bit u_adder_inc (
        .i_a    (i_current_pc),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (w_pc_plus_2),
        .o_cout (w_dummy_cout1)
    );

    // 2. Branch/JAL用ターゲットアドレスの計算 (PC + imm)
    next_pc_logic_adder_16bit u_adder_pc_rel (
        .i_a    (i_current_pc),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_pc_target),
        .o_cout (w_dummy_cout2)
    );

    // 3. JALR用ターゲットアドレスの計算 (rs1 + imm)
    next_pc_logic_adder_16bit u_adder_jalr (
        .i_a    (i_rs1_data),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_jalr_target),
        .o_cout (w_dummy_cout3)
    );

    // 4. 分岐条件の成否判定
    next_pc_logic_branch_resolver u_resolver (
        .i_is_blt (i_is_blt),
        .i_is_bz  (i_is_bz),
        .i_flag_z (i_flag_z),
        .i_flag_n (i_flag_n),
        .i_flag_v (i_flag_v),
        .o_taken  (w_branch_taken)
    );

    // 5. MUX用選択信号の最終決定
    // 制御ユニットからの信号(i_pc_sel_from_cu)と、実際の分岐成否を組み合わせて決定
    // 00: PC+2
    // 01: PC+imm (Branch Taken または JAL)
    // 10: rs1+imm (JALR)
    // 11: PC (Hold/Others)
    assign w_final_sel = (i_pc_sel_from_cu == 2'b01 && w_branch_taken) ? 2'b01 : // Branch Taken
                         (i_pc_sel_from_cu == 2'b10)                  ? 2'b01 : // JAL (PC相対)
                         (i_pc_sel_from_cu == 2'b11)                  ? 2'b10 : // JALR (レジスタ相対)
                                                                        2'b00;  // Normal / Branch Not Taken

    // 6. 次PCの選択
    next_pc_logic_mux_4to1_16bit u_mux (
        .i_sel (w_final_sel),
        .i_d0  (w_pc_plus_2),   // 00: sequential
        .i_d1  (w_pc_target),   // 01: PC+imm
        .i_d2  (w_jalr_target), // 10: rs1+imm
        .i_d3  (i_current_pc),  // 11: hold
        .o_y   (o_next_pc)
    );

    // 戻りアドレス用出力
    assign o_pc_plus_2 = w_pc_plus_2;

endmodule