module immediate_generator (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_sel,
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_type0; // 4-bit [7:4]   : addi, load, jalr
    wire [15:0] w_imm_type1; // 8-bit [11:4]  : loadi, jal
    wire [15:0] w_imm_type2; // 12-bit [15:4] : blt, bz
    wire [15:0] w_imm_type3; // 4-bit [15:12] : store

    // sign_ext_4to16 for addi/load/jalr
    immediate_generator_sign_ext_4to16 u_ext4_type0 (
        .i_imm_4  (i_instr[7:4]),
        .o_imm_16 (w_imm_type0)
    );

    // sign_ext_8to16 for loadi/jal
    immediate_generator_sign_ext_8to16 u_ext8_type1 (
        .i_imm_8  (i_instr[11:4]),
        .o_imm_16 (w_imm_type1)
    );

    // sign_ext_12to16 for blt/bz
    immediate_generator_sign_ext_12to16 u_ext12_type2 (
        .i_imm_12 (i_instr[15:4]),
        .o_imm_16 (w_imm_type2)
    );

    // sign_ext_4to16 for store
    immediate_generator_sign_ext_4to16 u_ext4_type3 (
        .i_imm_4  (i_instr[15:12]),
        .o_imm_16 (w_imm_type3)
    );

    // Select the correct extended immediate based on instruction type
    immediate_generator_mux4_16bit u_mux (
        .i_sel (i_imm_sel),
        .i_d0  (w_imm_type0),
        .i_d1  (w_imm_type1),
        .i_d2  (w_imm_type2),
        .i_d3  (w_imm_type3),
        .o_q   (o_imm)
    );

endmodule