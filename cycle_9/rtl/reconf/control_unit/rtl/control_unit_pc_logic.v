module control_unit_pc_logic (
    input  wire [15:0] i_inst_onehot,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire [1:0]  o_pc_sel      // 00:PC+2, 01:PC+imm, 10:rs1+imm
);

    // 分岐条件の判定 (N^V: Less Than, Z: Zero)
    wire w_condition_blt;
    wire w_condition_bz;
    wire w_branch_taken;

    assign w_condition_blt = i_flag_n ^ i_flag_v;
    assign w_condition_bz  = i_flag_z;

    // 分岐命令かつ条件成立の場合に成立信号を出す
    assign w_branch_taken = (i_inst_onehot[12] & w_condition_blt) | 
                            (i_inst_onehot[13] & w_condition_bz);

    // PC選択論理
    // o_pc_sel[0] = (条件成立分岐) OR (JAL) -> PC+immへ
    // o_pc_sel[1] = (JALR)                 -> rs1+immへ
    assign o_pc_sel[0] = w_branch_taken | i_inst_onehot[14];
    assign o_pc_sel[1] = i_inst_onehot[15];

endmodule