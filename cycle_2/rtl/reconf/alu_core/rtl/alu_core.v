module alu_core (
    input  wire [3:0]  i_alu_op,
    input  wire [15:0] i_rs1,
    input  wire [15:0] i_rs2,
    output wire [15:0] o_res,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    // 各演算ユニットからの中間結果
    wire [15:0] w_res_arith;
    wire [15:0] w_res_logic;
    wire [15:0] w_res_shift;

    // 算術演算用フラグ（オーバーフロー）
    wire        w_v_arith;

    // --- 1. 算術演算ブロック (Arithmetic) ---
    // opcode[0]を減算切り替え信号として使用 (0:ADD, 1:SUB)
    alu_core_arithmetic_16bit u_arith (
        .i_a    (i_rs1),
        .i_b    (i_rs2),
        .i_sub  (i_alu_op[0]),
        .o_sum  (w_res_arith),
        .o_v    (w_v_arith)
    );

    // --- 2. 論理演算ブロック (Logic) ---
    // opcode[1:0]により AND, OR, XOR, NOT を選択
    alu_core_logic_16bit u_logic (
        .i_a    (i_rs1),
        .i_b    (i_rs2),
        .i_op   (i_alu_op[1:0]),
        .o_res  (w_res_logic)
    );

    // --- 3. シフト演算ブロック (Shifter) ---
    // opcode[0]により SRA, SLA を選択
    alu_core_shifter_16bit u_shifter (
        .i_data (i_rs1),
        .i_sa   (i_rs2),
        .i_left (i_alu_op[0]),
        .o_res  (w_res_shift)
    );

    // --- 4. 結果選択部 (Multiplexer) ---
    // 演算結果候補をまとめ、opcodeの下位3ビットで最終出力を選択
    // 0,1: Arith, 2,3,4,5: Logic, 6,7: Shift
    alu_core_mux8_16bit u_mux8 (
        .i_sel (i_alu_op[2:0]),
        .i_d0  (w_res_arith), // 000: ADD
        .i_d1  (w_res_arith), // 001: SUB
        .i_d2  (w_res_logic), // 010: AND
        .i_d3  (w_res_logic), // 011: OR
        .i_d4  (w_res_logic), // 100: XOR
        .i_d5  (w_res_logic), // 101: NOT
        .i_d6  (w_res_shift), // 110: SRA
        .i_d7  (w_res_shift), // 111: SLA
        .o_y   (o_res)
    );

    // --- 5. フラグ算出部 (Flag Calculation) ---
    // 最終的な演算結果と演算器の状態からフラグを生成
    alu_core_flag_calc u_flag_calc (
        .i_res  (o_res),
        .i_v    (w_v_arith),
        .o_z    (o_flag_z),
        .o_n    (o_flag_n),
        .o_v    (o_flag_v)
    );

endmodule