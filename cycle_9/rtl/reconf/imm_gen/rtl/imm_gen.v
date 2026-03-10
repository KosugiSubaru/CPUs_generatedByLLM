module imm_gen (
    input  wire [3:0]  i_opcode,
    input  wire [3:0]  i_rd_addr,       // bits [15:12]
    input  wire [3:0]  i_rs2_addr,      // bits [7:4]
    input  wire [11:0] i_imm_raw_15_4,  // bits [15:4]
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_ext4_7_4;
    wire [15:0] w_imm_ext4_15_12;
    wire [15:0] w_imm_ext8;
    wire [15:0] w_imm_ext12;

    // I-type/JALR用 (bits 7:4) の拡張
    imm_gen_ext4 u_imm_gen_ext4_i (
        .i_imm (i_rs2_addr),
        .o_imm (w_imm_ext4_7_4)
    );

    // Store用 (bits 15:12) の拡張
    imm_gen_ext4 u_imm_gen_ext4_s (
        .i_imm (i_rd_addr),
        .o_imm (w_imm_ext4_15_12)
    );

    // loadi/jal用 (bits 11:4) の拡張
    imm_gen_ext8 u_imm_gen_ext8 (
        .i_imm (i_imm_raw_15_4[7:0]),
        .o_imm (w_imm_ext8)
    );

    // branch用 (bits 15:4) の拡張
    imm_gen_ext12 u_imm_gen_ext12 (
        .i_imm (i_imm_raw_15_4),
        .o_imm (w_imm_ext12)
    );

    // opcodeに基づき、最終的な即値を選択
    imm_gen_mux u_imm_gen_mux (
        .i_opcode           (i_opcode),
        .i_imm_ext4_7_4     (w_imm_ext4_7_4),
        .i_imm_ext4_15_12   (w_imm_ext4_15_12),
        .i_imm_ext8         (w_imm_ext8),
        .i_imm_ext12        (w_imm_ext12),
        .o_imm              (o_imm)
    );

endmodule