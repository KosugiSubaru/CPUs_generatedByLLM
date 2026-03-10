module next_pc_logic_ctrl (
    input  wire [3:0] i_opcode,
    input  wire       i_flag_z,
    input  wire       i_flag_n,
    input  wire       i_flag_v,
    output wire [1:0] o_sel
);

    wire w_is_blt;
    wire w_is_bz;
    wire w_is_jal;
    wire w_is_jalr;
    wire w_branch_taken;

    // 命令の識別
    assign w_is_blt  = (i_opcode == 4'b1100);
    assign w_is_bz   = (i_opcode == 4'b1101);
    assign w_is_jal  = (i_opcode == 4'b1110);
    assign w_is_jalr = (i_opcode == 4'b1111);

    // ISA定義に基づく分岐条件の判定
    // blt: N ^ V (符号付き less than)
    // bz : Z (zero)
    assign w_branch_taken = (w_is_blt & (i_flag_n ^ i_flag_v)) | 
                            (w_is_bz  & i_flag_z);

    // マルチプレクサ選択信号の生成
    // 00: PC + 2
    // 01: PC + imm (成立した分岐命令、またはJAL命令)
    // 10: rs1 + imm (JALR命令)
    assign o_sel[0] = w_branch_taken | w_is_jal;
    assign o_sel[1] = w_is_jalr;

endmodule