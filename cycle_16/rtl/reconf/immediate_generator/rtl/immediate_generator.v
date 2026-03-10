module immediate_generator (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_sel, // 00:TypeA, 01:TypeB, 10:TypeC, 11:TypeD
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_a;
    wire [15:0] w_imm_b;
    wire [15:0] w_imm_c;
    wire [15:0] w_imm_d;

    // L1: 命令語から4種類の即値形式を並列に抽出し、符号拡張を行う
    // Type A: addi, load, jalr (imm[7:4])
    // Type B: loadi, jal (imm[11:4])
    // Type C: store (imm[15:12])
    // Type D: blt, bz (imm[15:4])
    immediate_generator_formats u_formats (
        .i_instr (i_instr),
        .o_imm_a (w_imm_a),
        .o_imm_b (w_imm_b),
        .o_imm_c (w_imm_c),
        .o_imm_d (w_imm_d)
    );

    // L1: 抽出された候補から、制御信号に基づき1つを選択する
    // パタン構造化のため、16bit幅の4入力マルチプレクサをインスタンス化
    immediate_generator_mux_4to1_16bit u_mux (
        .i_sel (i_imm_sel),
        .i_d0  (w_imm_a),
        .i_d1  (w_imm_b),
        .i_d2  (w_imm_c),
        .i_d3  (w_imm_d),
        .o_q   (o_imm)
    );

endmodule