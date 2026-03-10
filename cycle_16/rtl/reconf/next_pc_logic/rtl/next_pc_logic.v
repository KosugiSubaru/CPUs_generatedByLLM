module next_pc_logic (
    input  wire [15:0] i_pc,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire [1:0]  i_pc_sel,    // 00:PC+2, 01:PC+imm, 10:rs1+imm
    output wire [15:0] o_next_pc
);

    wire [15:0] w_pc_plus_2;
    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;

    // L1: 16ビット加算器のインスタンス化 (PC + 2)
    next_pc_logic_adder_16bit u_adder_plus_2 (
        .i_a   (i_pc),
        .i_b   (16'h0002),
        .o_sum (w_pc_plus_2)
    );

    // L1: 16ビット加算器のインスタンス化 (PC + imm)
    // 分岐(blt, bz) または ジャンプ(jal) で使用
    next_pc_logic_adder_16bit u_adder_plus_imm (
        .i_a   (i_pc),
        .i_b   (i_imm),
        .o_sum (w_pc_plus_imm)
    );

    // L1: 16ビット加算器のインスタンス化 (rs1 + imm)
    // ジャンプ(jalr) で使用
    next_pc_logic_adder_16bit u_adder_rs1_imm (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_rs1_plus_imm)
    );

    // L1: 16ビット幅 4入力マルチプレクサのインスタンス化
    // 制御信号(i_pc_sel)に基づき、次のPC値を決定
    next_pc_logic_mux_4to1_16bit u_mux_next (
        .i_sel (i_pc_sel),
        .i_d0  (w_pc_plus_2),    // 通常
        .i_d1  (w_pc_plus_imm),  // 分岐成立/JAL
        .i_d2  (w_rs1_plus_imm), // JALR
        .i_d3  (w_pc_plus_2),    // 予備(通常)
        .o_q   (o_next_pc)
    );

endmodule