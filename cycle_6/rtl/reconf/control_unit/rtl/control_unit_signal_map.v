module control_unit_signal_map (
    input  wire [15:0] i_inst_onehot,
    input  wire        i_branch_taken,
    output wire        o_reg_write,
    output wire        o_mem_write,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_sel,
    output wire [1:0]  o_mem_to_reg,
    output wire [1:0]  o_pc_sel
);

    // RegWrite: store(11), blt(12), bz(13) 以外の命令で有効
    assign o_reg_write = i_inst_onehot[0]  | i_inst_onehot[1]  | i_inst_onehot[2]  |
                         i_inst_onehot[3]  | i_inst_onehot[4]  | i_inst_onehot[5]  |
                         i_inst_onehot[6]  | i_inst_onehot[7]  | i_inst_onehot[8]  |
                         i_inst_onehot[9]  | i_inst_onehot[10] | i_inst_onehot[14] |
                         i_inst_onehot[15];

    // MemWrite: store(11) 命令のみ有効
    assign o_mem_write = i_inst_onehot[11];

    // ALUSrc: addi(8), loadi(9), load(10), store(11) の場合に即値を選択(1)
    assign o_alu_src_sel = i_inst_onehot[8] | i_inst_onehot[9] | i_inst_onehot[10] | i_inst_onehot[11];

    // MemToReg: 00:ALU result, 01:Mem data, 10:PC+2
    assign o_mem_to_reg[0] = i_inst_onehot[10]; // load
    assign o_mem_to_reg[1] = i_inst_onehot[14] | i_inst_onehot[15]; // jal, jalr

    // PCSel (CU Output to NextPC Logic):
    // 00: Normal(PC+2), 01: Branch(12,13), 10: JAL(14), 11: JALR(15)
    // 実際の分岐成立判定は next_pc_logic モジュール内で行うため、ここでは命令タイプを渡す
    assign o_pc_sel[0] = i_inst_onehot[12] | i_inst_onehot[13] | i_inst_onehot[15];
    assign o_pc_sel[1] = i_inst_onehot[14] | i_inst_onehot[15];

    // ALUOp: I-type(addi, load, store)は加算(0000)に固定
    assign o_alu_op[0] = i_inst_onehot[1] | i_inst_onehot[3] | i_inst_onehot[5] | i_inst_onehot[7];
    assign o_alu_op[1] = i_inst_onehot[2] | i_inst_onehot[3] | i_inst_onehot[6] | i_inst_onehot[7];
    assign o_alu_op[2] = i_inst_onehot[4] | i_inst_onehot[5] | i_inst_onehot[6] | i_inst_onehot[7];
    assign o_alu_op[3] = i_inst_onehot[9]; // loadi (パススルー)

endmodule