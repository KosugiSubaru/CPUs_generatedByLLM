module pc_unit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,    // 00:Normal/JAL, 01:Branch, 10:JALR
    input  wire [15:0] i_imm,       // Decoder/ImmGenからの符号拡張済み即値
    input  wire [15:0] i_rs1_data,  // JALR命令で使用するレジスタ値
    output wire [15:0] o_pc,        // 命令メモリへのアドレス
    output wire [15:0] o_pc_plus_2  // jal/jalr命令での戻りアドレス(rd書き込み用)
);

    wire [15:0] w_current_pc;
    wire [15:0] w_next_pc;
    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;

    // 現在のPC値を外部（命令メモリ）へ出力
    assign o_pc = w_current_pc;

    // PCレジスタ本体（L1階層: 16bit同期レジスタ）
    pc_unit_reg_16bit u_reg_pc (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_data  (w_next_pc),
        .o_pc    (w_current_pc)
    );

    // 次のアドレス計算：PC + 2 (通常のインクリメント)
    pc_unit_adder_16bit u_adder_plus_2 (
        .i_a   (w_current_pc),
        .i_b   (16'h0002),
        .o_sum (o_pc_plus_2)
    );

    // 次のアドレス計算：PC + imm (JALおよびBranch条件成立時)
    pc_unit_adder_16bit u_adder_plus_imm (
        .i_a   (w_current_pc),
        .i_b   (i_imm),
        .o_sum (w_pc_plus_imm)
    );

    // 次のアドレス計算：rs1 + imm (JALR命令)
    pc_unit_adder_16bit u_adder_jalr (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_rs1_plus_imm)
    );

    // 次のPC値の選択（L1階層: 16bit 3-to-1マルチプレクサ）
    pc_unit_mux_3to1_16bit u_mux_next_pc (
        .i_sel  (i_pc_sel),
        .i_d0   (o_pc_plus_2),    // 通常時
        .i_d1   (w_pc_plus_imm),  // Branch/JAL
        .i_d2   (w_rs1_plus_imm), // JALR
        .o_data (w_next_pc)
    );

endmodule