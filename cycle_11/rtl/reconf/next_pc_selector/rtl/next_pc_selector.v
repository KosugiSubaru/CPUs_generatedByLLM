module next_pc_selector (
    input  wire [3:0]  i_opcode,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    input  wire [1:0]  i_pc_src_sel,
    input  wire        i_is_branch,
    input  wire [15:0] i_pc_plus_2,
    input  wire [15:0] i_pc_target,
    input  wire [15:0] i_rs1_target,
    output wire [15:0] o_next_pc
);

    wire       w_branch_taken;
    wire [1:0] w_final_pc_sel;

    next_pc_selector_br_eval u_br_eval (
        .i_opcode (i_opcode),
        .i_flag_z (i_flag_z),
        .i_flag_n (i_flag_n),
        .i_flag_v (i_flag_v),
        .o_taken  (w_branch_taken)
    );

    // 修正：条件分岐命令(i_is_branch)の場合は判定ユニットの結果(w_branch_taken)を優先する。
    // 条件成立時は 2'b01 (PC+imm) を、不成立時は 2'b00 (PC+2) を選択。
    // 分岐命令以外（JAL/JALR/通常）の場合は、デコーダの信号(i_pc_src_sel)をそのまま使用する。
    assign w_final_pc_sel = (i_is_branch) ? (w_branch_taken ? 2'b01 : 2'b00) : i_pc_src_sel;

    next_pc_selector_mux_16bit u_mux_16bit (
        .i_sel (w_final_pc_sel),
        .i_d0  (i_pc_plus_2),
        .i_d1  (i_pc_target),
        .i_d2  (i_rs1_target),
        .i_d3  (16'h0000),
        .o_y   (o_next_pc)
    );

endmodule