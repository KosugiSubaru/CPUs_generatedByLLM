module pc_logic (
    input  wire [15:0] i_now_pc,
    input  wire [15:0] i_rs1_data,
    input  wire [15:0] i_imm,
    input  wire        i_pc_src_sel,  // 0: PC+2, 1: Target
    input  wire        i_pc_base_sel, // 0: PC, 1: rs1
    output wire [15:0] o_next_pc,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_base_addr;
    wire [15:0] w_target_addr;

    // 1. PC+2の計算 (インクリメント)
    pc_logic_adder_16bit u_adder_pc_plus_2 (
        .i_a    (i_now_pc),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (o_pc_plus_2),
        .o_cout ()
    );

    // 2. ターゲット計算用のベースアドレス選択 (PC vs rs1)
    pc_logic_mux2to1_16bit u_mux_base (
        .i_sel  (i_pc_base_sel),
        .i_data0(i_now_pc),
        .i_data1(i_rs1_data),
        .o_data (w_base_addr)
    );

    // 3. ターゲットアドレスの計算 (Base + Imm)
    pc_logic_adder_16bit u_adder_target (
        .i_a    (w_base_addr),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_target_addr),
        .o_cout ()
    );

    // 4. 次サイクルのPC選択 (PC+2 vs Target)
    pc_logic_mux2to1_16bit u_mux_next_pc (
        .i_sel  (i_pc_src_sel),
        .i_data0(o_pc_plus_2),
        .i_data1(w_target_addr),
        .o_data (o_next_pc)
    );

endmodule