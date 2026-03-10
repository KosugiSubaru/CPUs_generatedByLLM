module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire        i_pc_target_sel,  // 0: PC+imm, 1: rs1+imm
    input  wire        i_pc_jump_taken,  // 0: PC+2, 1: Jump/Branch Target
    output wire [15:0] o_pc_now,         // 命令メモリへのアドレス
    output wire [15:0] o_pc_plus_2       // リンクレジスタ書き込み用 (PC+2)
);

    wire [15:0] w_next_pc;

    // PC値を保持するレジスタ
    program_counter_register u_register (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_next_pc (w_next_pc),
        .o_pc_now  (o_pc_now)
    );

    // 次のPC値を計算・選択する組合せ論理
    program_counter_logic u_logic (
        .i_pc_now        (o_pc_now),
        .i_imm           (i_imm),
        .i_rs1_data      (i_rs1_data),
        .i_pc_target_sel (i_pc_target_sel),
        .i_pc_jump_taken (i_pc_jump_taken),
        .o_next_pc       (w_next_pc),
        .o_pc_plus_2     (o_pc_plus_2)
    );

endmodule