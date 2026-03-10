module pc_control (
    input  wire [15:0] i_pc_current,
    input  wire [15:0] i_rs1_data,
    input  wire [15:0] i_imm,
    input  wire [3:0]  i_opcode,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    input  wire        i_branch,
    input  wire        i_jump,
    input  wire        i_jump_reg,
    output wire [15:0] o_pc_next,
    output wire [15:0] o_pc_plus2
);

    wire [15:0] w_pc_plus2;
    wire [15:0] w_rel_target;
    wire [15:0] w_abs_target;
    wire        w_cond_met;
    wire [1:0]  w_sel;

    // PC + 2 計算
    pc_control_adder_16bit u_adder_plus2 (
        .i_a   (i_pc_current),
        .i_b   (16'h0002),
        .o_sum (w_pc_plus2)
    );

    // PC + imm 計算 (Branch, jal用)
    pc_control_adder_16bit u_adder_rel (
        .i_a   (i_pc_current),
        .i_b   (i_imm),
        .o_sum (w_rel_target)
    );

    // rs1 + imm 計算 (jalr用)
    pc_control_adder_16bit u_adder_abs (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_abs_target)
    );

    // 分岐条件判定
    pc_control_cond_check u_cond_check (
        .i_opcode   (i_opcode),
        .i_flag_z   (i_flag_z),
        .i_flag_n   (i_flag_n),
        .i_flag_v   (i_flag_v),
        .o_cond_met (w_cond_met)
    );

    // MUX選択信号生成
    // 00: PC+2, 01: PC+imm(Branch), 10: rs1+imm(JALR), 11: PC+imm(JAL)
    assign w_sel[1] = i_jump_reg | i_jump;
    assign w_sel[0] = i_jump | (i_branch & w_cond_met);

    assign o_pc_plus2 = w_pc_plus2;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_mux
            pc_control_mux_1bit u_mux (
                .i_sel (w_sel),
                .i_d0  (w_pc_plus2[i]),
                .i_d1  (w_rel_target[i]),
                .i_d2  (w_abs_target[i]),
                .i_d3  (w_rel_target[i]),
                .o_q   (o_pc_next[i])
            );
        end
    endgenerate

endmodule