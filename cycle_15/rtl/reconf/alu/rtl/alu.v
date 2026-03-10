module alu (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_opcode,      // ALU演算種別
    output wire [15:0] o_result,      // 演算結果
    output wire        o_flag_z,      // ゼロフラグ
    output wire        o_flag_n,      // 負フラグ
    output wire        o_flag_v       // オーバーフローフラグ
);

    // 各ユニットからの演算結果候補
    wire [15:0] w_res_add;
    wire [15:0] w_res_sub;
    wire [15:0] w_res_and;
    wire [15:0] w_res_or;
    wire [15:0] w_res_xor;
    wire [15:0] w_res_not;
    wire [15:0] w_res_sra;
    wire [15:0] w_res_sla;

    // 算術演算ユニット (加算・減算)
    alu_arithmetic_unit u_arith (
        .i_a       (i_a),
        .i_b       (i_b),
        .o_res_add (w_res_add),
        .o_res_sub (w_res_sub)
    );

    // 論理演算ユニット (AND, OR, XOR, NOT)
    alu_logic_unit u_logic (
        .i_a       (i_a),
        .i_b       (i_b),
        .o_res_and (w_res_and),
        .o_res_or  (w_res_or),
        .o_res_xor (w_res_xor),
        .o_res_not (w_res_not)
    );

    // シフト演算ユニット (SRA, SLA)
    alu_shift_unit u_shift (
        .i_a       (i_a),
        .i_b       (i_b),
        .o_res_sra (w_res_sra),
        .o_res_sla (w_res_sla)
    );

    // 演算結果の最終選択 (Opcodeの下位3ビットを使用)
    // 000:Add, 001:Sub, 010:And, 011:Or, 100:Xor, 101:Not, 110:Sra, 111:Sla
    alu_mux_8to1_16bit u_mux_select (
        .i_sel (i_opcode[2:0]),
        .i_d0  (w_res_add),
        .i_d1  (w_res_sub),
        .i_d2  (w_res_and),
        .i_d3  (w_res_or),
        .i_d4  (w_res_xor),
        .i_d5  (w_res_not),
        .i_d6  (w_res_sra),
        .i_d7  (w_res_sla),
        .o_data(o_result)
    );

    // フラグ生成ロジック
    alu_flag_logic u_flag_gen (
        .i_a       (i_a),
        .i_b       (i_b),
        .i_opcode  (i_opcode),
        .i_result  (o_result),
        .o_flag_z  (o_flag_z),
        .o_flag_n  (o_flag_n),
        .o_flag_v  (o_flag_v)
    );

endmodule