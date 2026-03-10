module next_pc_logic (
    input  wire [15:0] i_pc,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire [3:0]  i_opcode,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire [15:0] o_next_pc
);

    wire [15:0] w_pc_p2;
    wire [15:0] w_pc_imm;
    wire [15:0] w_rs1_imm;
    wire [1:0]  w_sel;

    // 次PC候補0: PC + 2 (通常進行)
    next_pc_logic_adder_16bit u_adder_p2 (
        .i_a   (i_pc),
        .i_b   (16'h0002),
        .o_sum (w_pc_p2)
    );

    // 次PC候補1: PC + imm (条件分岐、またはJAL)
    next_pc_logic_adder_16bit u_adder_imm (
        .i_a   (i_pc),
        .i_b   (i_imm),
        .o_sum (w_pc_imm)
    );

    // 次PC候補2: rs1 + imm (JALR)
    next_pc_logic_adder_16bit u_adder_jalr (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_rs1_imm)
    );

    // opcodeとフラグの状態に基づき、どの計算パスを次PCにするか決定
    next_pc_logic_ctrl u_ctrl (
        .i_opcode (i_opcode),
        .i_flag_z (i_flag_z),
        .i_flag_n (i_flag_n),
        .i_flag_v (i_flag_v),
        .o_sel    (w_sel)
    );

    // デコードされた制御信号に基づき、最終的な次PC値を選択
    // 00: PC+2, 01: PC+imm, 10: rs1+imm
    next_pc_logic_mux_4to1_16bit u_mux (
        .i_d0  (w_pc_p2),
        .i_d1  (w_pc_imm),
        .i_d2  (w_rs1_imm),
        .i_d3  (16'h0000),
        .i_sel (w_sel),
        .o_q   (o_next_pc)
    );

endmodule