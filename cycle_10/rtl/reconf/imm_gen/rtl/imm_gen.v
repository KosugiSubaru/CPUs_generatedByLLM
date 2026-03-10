module imm_gen (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_i;
    wire [15:0] w_imm_s;
    wire [15:0] w_imm_l;
    wire [15:0] w_imm_b;
    wire [1:0]  w_imm_sel;
    wire [3:0]  w_opcode;

    assign w_opcode = i_instr[3:0];

    // I形式のエクステンダ (addi: rd[15:12]+rs1[11:8]+imm[7:4]+opcode[3:0])
    imm_gen_ext4_i u_ext_i (
        .i_instr (i_instr),
        .o_imm   (w_imm_i)
    );

    // S形式のエクステンダ (store: imm[15:12]+rs1[11:8]+rs2[7:4]+opcode[3:0])
    imm_gen_ext4_s u_ext_s (
        .i_instr (i_instr),
        .o_imm   (w_imm_s)
    );

    // L形式のエクステンダ (loadi, jal: rd[15:12]+imm[11:4]+opcode[3:0])
    imm_gen_ext8 u_ext_l (
        .i_instr (i_instr),
        .o_imm   (w_imm_l)
    );

    // B形式のエクステンダ (blt, bz: imm[15:4]+opcode[3:0])
    imm_gen_ext12 u_ext_b (
        .i_instr (i_instr),
        .o_imm   (w_imm_b)
    );

    // 命令のOpcodeから即値の形式を選択するセレクタ信号の生成
    // 00: I形式 (addi, load, jalr)
    // 01: S形式 (store)
    // 10: L形式 (loadi, jal)
    // 11: B形式 (blt, bz)
    assign w_imm_sel[1] = (w_opcode == 4'b1001) | (w_opcode == 4'b1110) | (w_opcode == 4'b1100) | (w_opcode == 4'b1101);
    assign w_imm_sel[0] = (w_opcode == 4'b1011) | (w_opcode == 4'b1100) | (w_opcode == 4'b1101);

    // 各形式の出力から最終的な1つを選択するMUX
    imm_gen_mux_4to1 u_mux (
        .i_data_i (w_imm_i),
        .i_data_s (w_imm_s),
        .i_data_l (w_imm_l),
        .i_data_b (w_imm_b),
        .i_sel    (w_imm_sel),
        .o_imm    (o_imm)
    );

endmodule