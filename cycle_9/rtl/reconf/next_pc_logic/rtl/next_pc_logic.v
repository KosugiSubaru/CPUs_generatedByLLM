module next_pc_logic (
    input  wire [15:0] i_now_pc,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire [1:0]  i_pc_sel,
    output wire [15:0] o_next_pc,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_target_base;
    wire [15:0] w_target_addr;
    wire        w_final_sel;

    // 通常のインクリメント計算 (PC + 2)
    next_pc_logic_adder u_adder_pc_inc (
        .i_a    (i_now_pc),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (o_pc_plus_2),
        .o_cout ()
    );

    // ジャンプ先計算の基点を選択 (0:PC, 1:rs1)
    // i_pc_sel[1] が 1 のとき JALR (rs1基準) となる
    next_pc_logic_mux_16bit u_mux_target_base (
        .i_d0  (i_now_pc),
        .i_d1  (i_rs1_data),
        .i_sel (i_pc_sel[1]),
        .o_q   (w_target_base)
    );

    // ジャンプ先アドレスの計算 (Base + imm)
    next_pc_logic_adder u_adder_target_addr (
        .i_a    (w_target_base),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_target_addr),
        .o_cout ()
    );

    // 最終的な次PCの選択論理
    // i_pc_sel のいずれかのビットが立っていればジャンプ先を採用する
    assign w_final_sel = i_pc_sel[0] | i_pc_sel[1];

    // PC+2 か 計算したターゲットアドレスかを選択
    next_pc_logic_mux_16bit u_mux_final_pc (
        .i_d0  (o_pc_plus_2),
        .i_d1  (w_target_addr),
        .i_sel (w_final_sel),
        .o_q   (o_next_pc)
    );

endmodule