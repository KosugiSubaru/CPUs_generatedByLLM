module alu_core (
    input  wire [3:0]  i_alu_op,     // 演算種別 (Opcode[3:0])
    input  wire [15:0] i_data_a,     // rs1
    input  wire [15:0] i_data_b,     // rs2 または imm
    output wire [15:0] o_result,     // 演算結果
    output wire        o_flag_z,     // ゼロフラグ
    output wire        o_flag_n,     // 負フラグ
    output wire        o_flag_v      // オーバーフローフラグ
);

    wire [15:0] w_arith_res;
    wire [15:0] w_logic_res;
    wire [15:0] w_shift_res;
    wire        w_arith_v;

    // 算術演算制御: Opcode 0001 (sub) の時に減算を有効化
    wire w_sub_en;
    assign w_sub_en = (i_alu_op == 4'b0001);

    // L1: 算術演算ブロック (加算・減算)
    alu_core_arithmetic_16bit u_arith (
        .i_a      (i_data_a),
        .i_b      (i_data_b),
        .i_sub_en (w_sub_en),
        .o_sum    (w_arith_res),
        .o_v      (w_arith_v)
    );

    // L1: 論理演算ブロック (AND, OR, XOR, NOT)
    // Opcode 0010(AND), 0011(OR), 0100(XOR), 0101(NOT) の下位2bitを渡す
    alu_core_logic_16bit u_logic (
        .i_a      (i_data_a),
        .i_b      (i_data_b),
        .i_sel    (i_alu_op[1:0]),
        .o_out    (w_logic_res)
    );

    // L1: シフト演算ブロック (SRA, SLA)
    // Opcode 0110(SRA), 0111(SLA)
    alu_core_shifter_16bit u_shifter (
        .i_a      (i_data_a),
        .i_b      (i_data_b),
        .i_right  (i_alu_op == 4'b0110),
        .o_out    (w_shift_res)
    );

    // L1: 最終結果の選択 (8-to-1 MUX)
    // Opcode 000-001:Arith, 010-101:Logic, 110-111:Shift
    alu_core_mux_8to1_16bit u_mux (
        .i_sel (i_alu_op[2:0]),
        .i_d0  (w_arith_res), // add
        .i_d1  (w_arith_res), // sub
        .i_d2  (w_logic_res), // and
        .i_d3  (w_logic_res), // or
        .i_d4  (w_logic_res), // xor
        .i_d5  (w_logic_res), // not
        .i_d6  (w_shift_res), // sra
        .i_d7  (w_shift_res), // sla
        .o_q   (o_result)
    );

    // フラグ出力の集約
    // Zフラグ: 全ビットが0の場合に1
    assign o_flag_z = (o_result == 16'h0000);

    // Nフラグ: 結果の最上位ビット
    assign o_flag_n = o_result[15];

    // Vフラグ: 加減算(Opcode 0XXX)の時のみ算術ブロックのVフラグを有効化
    assign o_flag_v = w_arith_v & (~i_alu_op[3] & ~i_alu_op[2]);

endmodule