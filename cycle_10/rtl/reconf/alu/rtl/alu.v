module alu (
    input  wire [15:0] i_rs1_data,
    input  wire [15:0] i_rs2_data,
    input  wire [3:0]  i_alu_op,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_adder_res;
    wire [15:0] w_logical_res;
    wire [15:0] w_shifter_res;
    wire [2:0]  w_mux_sel;
    wire        w_adder_v;

    // 算術演算ユニット (加算・減算・アドレス計算)
    alu_adder_16bit u_adder (
        .i_a   (i_rs1_data),
        .i_b   (i_rs2_data),
        .i_sub (i_alu_op == 4'b0001), // 0001の時のみ減算モード
        .o_sum (w_adder_res),
        .o_v   (w_adder_v)
    );

    // 論理演算ユニット (AND, OR, XOR, NOT)
    alu_logical_16bit u_logical (
        .i_a   (i_rs1_data),
        .i_b   (i_rs2_data),
        .i_op  (i_alu_op[2:0]),
        .o_res (w_logical_res)
    );

    // シフト演算ユニット (SRA, SLA)
    alu_shifter_16bit u_shifter (
        .i_a   (i_rs1_data),
        .i_b   (i_rs2_data), // 下位ビットをシフト量として使用
        .i_op  (i_alu_op[0]), // 0:SRA, 1:SLA
        .o_res (w_shifter_res)
    );

    // 演算結果の選択信号生成
    // I-type命令 (Opcode[3]==1) の場合、加算結果を選択する
    assign w_mux_sel = (i_alu_op[3]) ? 3'b000 : i_alu_op[2:0];

    // 8入力MUXによる最終演算結果の選択
    alu_mux_8to1 u_mux (
        .i_in0 (w_adder_res),   // Add / Addi / Load / Store / Jalr
        .i_in1 (w_adder_res),   // Sub
        .i_in2 (w_logical_res), // And
        .i_in3 (w_logical_res), // Or
        .i_in4 (w_logical_res), // Xor
        .i_in5 (w_logical_res), // Not
        .i_in6 (w_shifter_res), // Sra
        .i_in7 (w_shifter_res), // Sla
        .i_sel (w_mux_sel),
        .o_out (o_result)
    );

    // フラグ生成ロジック
    alu_flag_logic u_flags (
        .i_result  (o_result),
        .i_adder_v (w_adder_v),
        .i_alu_op  (i_alu_op),
        .o_z       (o_flag_z),
        .o_n       (o_flag_n),
        .o_v       (o_flag_v)
    );

endmodule