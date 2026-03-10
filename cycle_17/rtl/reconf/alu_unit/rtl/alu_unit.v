module alu_unit (
    input  wire [3:0]  i_alu_op,      // デコーダからの演算選択信号
    input  wire [15:0] i_rs1_data,   // 演算入力A
    input  wire [15:0] i_rs2_or_imm, // 演算入力B
    output wire [15:0] o_alu_result, // 演算結果
    output wire        o_f_z,        // ゼロフラグ
    output wire        o_f_n,        // 負フラグ
    output wire        o_f_v         // オーバーフローフラグ
);

    wire [15:0] w_add_sub_res;
    wire        w_add_sub_cout;
    wire [15:0] w_and_res;
    wire [15:0] w_or_res;
    wire [15:0] w_xor_res;
    wire [15:0] w_not_res;
    wire [15:0] w_sra_res;
    wire [15:0] w_sla_res;

    // 1. 加減算ユニットのインスタンス化 (Op: 0000, 0001)
    alu_unit_adder_16bit u_adder (
        .i_a      (i_rs1_data),
        .i_b      (i_rs2_or_imm),
        .i_sub_en (i_alu_op[0]), // Op 0001 の時にHigh
        .o_sum    (w_add_sub_res),
        .o_cout   (w_add_sub_cout)
    );

    // 2. 論理演算ユニットのインスタンス化 (Op: 0010, 0011, 0100, 0101)
    alu_unit_logic_16bit u_logic (
        .i_a   (i_rs1_data),
        .i_b   (i_rs2_or_imm),
        .o_and (w_and_res),
        .o_or  (w_or_res),
        .o_xor (w_xor_res),
        .o_not (w_not_res)
    );

    // 3. シフト演算ユニットのインスタンス化 (Op: 0110, 0111)
    alu_unit_shifter_16bit u_shifter (
        .i_data  (i_rs1_data),
        .i_shamt (i_rs2_or_imm[3:0]), // rs2の下位4ビットをシフト量として使用
        .o_sra   (w_sra_res),
        .o_sla   (w_sla_res)
    );

    // 4. 演算結果選択マルチプレクサ (8入力16ビット)
    alu_unit_mux8_16bit u_mux_result (
        .i_sel (i_alu_op[2:0]),
        .i_d0  (w_add_sub_res), // 000: Add
        .i_d1  (w_add_sub_res), // 001: Sub
        .i_d2  (w_and_res),     // 010: And
        .i_d3  (w_or_res),      // 011: Or
        .i_d4  (w_xor_res),     // 100: Xor
        .i_d5  (w_not_res),     // 101: Not
        .i_d6  (w_sra_res),     // 110: SRA
        .i_d7  (w_sla_res),     // 111: SLA
        .o_y   (o_alu_result)
    );

    // 5. フラグ生成ユニット
    alu_unit_flags u_flags (
        .i_rd     (o_alu_result),
        .i_rs1    (i_rs1_data),
        .i_rs2    (i_rs2_or_imm),
        .i_is_sub (i_alu_op[0]),
        .o_f_z    (o_f_z),
        .o_f_n    (o_f_n),
        .o_f_v    (o_f_v)
    );

endmodule