module imm_gen (
    input  wire [15:0] i_instr,
    input  wire [2:0]  i_imm_sel, // 0:0, 1:Ext4_I, 2:Ext4_S, 3:Ext8, 4:Ext12
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_ext4_i;
    wire [15:0] w_imm_ext4_s;
    wire [15:0] w_imm_ext8;
    wire [15:0] w_imm_ext12;

    // ISA: I形式 (addi, load, jalr) -> [7:4]
    imm_gen_ext4_i u_ext4_i (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext4_i)
    );

    // ISA: S形式 (store) -> [15:12]
    imm_gen_ext4_s u_ext4_s (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext4_s)
    );

    // ISA: L形式 (loadi, jal) -> [11:4]
    imm_gen_ext8 u_ext8 (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext8)
    );

    // ISA: B形式 (blt, bz) -> [15:4]
    imm_gen_ext12 u_ext12 (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext12)
    );

    // 抽出された即値から、命令種別に応じたものを選択
    imm_gen_mux5_16bit u_mux (
        .i_sel (i_imm_sel),
        .i_d0  (16'h0000),
        .i_d1  (w_imm_ext4_i),
        .i_d2  (w_imm_ext4_s),
        .i_d3  (w_imm_ext8),
        .i_d4  (w_imm_ext12),
        .o_q   (o_imm)
    );

endmodule