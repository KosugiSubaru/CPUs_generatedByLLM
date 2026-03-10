module pc_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,      // 00: PC+2, 01: PC+imm, 10: rs1+imm, 11: Hold
    input  wire [15:0] i_imm,         // 符号拡張済み即値
    input  wire [15:0] i_rs1_data,    // jalr用レジスタ値
    output wire [15:0] o_now_pc,      // 命令メモリ（imem）へのアドレス
    output wire [15:0] o_pc_plus_2    // rdへの戻り先アドレス (jal, jalr用)
);

    // 内部接続用ワイヤ
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;
    wire [15:0] w_next_pc;

    // ISA: 通常の命令更新 (PC + 2)
    pc_reg_adder_16bit u_adder_inc (
        .i_a     (o_now_pc),
        .i_b     (16'h0002),
        .o_sum   (w_pc_plus_2)
    );

    // ISA: 条件分岐・相対ジャンプ (PC + imm)
    pc_reg_adder_16bit u_adder_rel (
        .i_a     (o_now_pc),
        .i_b     (i_imm),
        .o_sum   (w_pc_plus_imm)
    );

    // ISA: レジスタ間接ジャンプ (rs1 + imm)
    pc_reg_adder_16bit u_adder_ind (
        .i_a     (i_rs1_data),
        .i_b     (i_imm),
        .o_sum   (w_rs1_plus_imm)
    );

    // ISA: 次のPCを選択するマルチプレクサ
    pc_reg_mux4_16bit u_mux_next_pc (
        .i_sel   (i_pc_sel),
        .i_d0    (w_pc_plus_2),
        .i_d1    (w_pc_plus_imm),
        .i_d2    (w_rs1_plus_imm),
        .i_d3    (o_now_pc),
        .o_q     (w_next_pc)
    );

    // PCレジスタ本体（状態保持）
    pc_reg_dff_16bit u_pc_state (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_next_pc),
        .o_q     (o_now_pc)
    );

    // jal/jalr命令でrdに書き込むための戻りアドレスを出力
    assign o_pc_plus_2 = w_pc_plus_2;

endmodule