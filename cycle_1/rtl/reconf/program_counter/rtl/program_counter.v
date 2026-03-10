module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,      // 00:PC+2, 01:PC+Imm, 10:rs1+Imm
    input  wire [15:0] i_imm,         // 符号拡張済み即値
    input  wire [15:0] i_rs1_data,    // jalr用ベースレジスタ値
    output wire [15:0] o_pc_current,  // 命令メモリへのアドレス
    output wire [15:0] o_pc_plus_2    // rdへの保存用(jal/jalr)
);

    wire [15:0] w_pc_next;
    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;
    wire        w_unused_cout1;
    wire        w_unused_cout2;
    wire        w_unused_cout3;

    // 現在のPC値を保持する16ビットレジスタ
    program_counter_nbit_register u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_pc_next),
        .o_q     (o_pc_current)
    );

    // 次の命令アドレス (PC + 2) の計算
    program_counter_adder_16bit u_adder_plus2 (
        .i_a    (o_pc_current),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (o_pc_plus_2),
        .o_cout (w_unused_cout1)
    );

    // 分岐・相対ジャンプアドレス (PC + Imm) の計算
    program_counter_adder_16bit u_adder_pc_imm (
        .i_a    (o_pc_current),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_pc_plus_imm),
        .o_cout (w_unused_cout2)
    );

    // レジスタ間接ジャンプアドレス (rs1 + Imm) の計算
    program_counter_adder_16bit u_adder_rs1_imm (
        .i_a    (i_rs1_data),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_rs1_plus_imm),
        .o_cout (w_unused_cout3)
    );

    // 次のサイクルでPCにセットする値の選択
    program_counter_nbit_mux_4to1 u_pc_sel_mux (
        .i_sel  (i_pc_sel),
        .i_d0   (o_pc_plus_2),     // 通常実行
        .i_d1   (w_pc_plus_imm),   // 分岐成立 / jal
        .i_d2   (w_rs1_plus_imm),  // jalr
        .i_d3   (16'h0000),        // 未使用
        .o_data (w_pc_next)
    );

endmodule