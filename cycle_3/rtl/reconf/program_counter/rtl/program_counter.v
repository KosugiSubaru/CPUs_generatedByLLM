module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_opcode,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    output wire [15:0] o_pc,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_next_pc;
    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;
    wire [1:0]  w_sel;

    // 現在のPC値を保持する16ビットレジスタ
    program_counter_reg u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_next_pc),
        .o_q     (o_pc)
    );

    // 次の命令アドレス (PC + 2) の計算
    program_counter_adder_16bit u_adder_p2 (
        .i_a   (o_pc),
        .i_b   (16'h0002),
        .o_sum (o_pc_plus_2)
    );

    // 相対ジャンプ・分岐先アドレス (PC + imm) の計算
    program_counter_adder_16bit u_adder_imm (
        .i_a   (o_pc),
        .i_b   (i_imm),
        .o_sum (w_pc_plus_imm)
    );

    // レジスタ接合ジャンプ先アドレス (rs1 + imm) の計算
    program_counter_adder_16bit u_adder_jalr (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_rs1_plus_imm)
    );

    // ISAの分岐条件に基づき、どのパスを選択するかを決定する制御ユニット
    program_counter_control u_pc_ctrl (
        .i_opcode (i_opcode),
        .i_flag_z (i_flag_z),
        .i_flag_n (i_flag_n),
        .i_flag_v (i_flag_v),
        .o_sel    (w_sel)
    );

    // 次のサイクルでPCにロードする値を選択
    // 00: PC+2, 01: PC+imm, 10: rs1+imm, 11: reserved
    program_counter_mux_4to1_16bit u_pc_mux (
        .i_d0  (o_pc_plus_2),
        .i_d1  (w_pc_plus_imm),
        .i_d2  (w_rs1_plus_imm),
        .i_d3  (16'h0000),
        .i_sel (w_sel),
        .o_q   (w_next_pc)
    );

endmodule