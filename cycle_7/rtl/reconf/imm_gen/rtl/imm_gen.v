module imm_gen (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_sel,
    output wire [15:0] o_imm
);

    wire [15:0] w_imm4_type_a;
    wire [15:0] w_imm4_type_b;
    wire [15:0] w_imm8;
    wire [15:0] w_imm12;

    // Type A: 4bit immediate from bits [7:4] (addi, load, jalr)
    imm_gen_ext_4to16 u_ext4_a (
        .i_in  (i_instr[7:4]),
        .o_out (w_imm4_type_a)
    );

    // Type B: 4bit immediate from bits [15:12] (store)
    imm_gen_ext_4to16 u_ext4_b (
        .i_in  (i_instr[15:12]),
        .o_out (w_imm4_type_b)
    );

    // Type C: 8bit immediate from bits [11:4] (loadi, jal)
    imm_gen_ext_8to16 u_ext8 (
        .i_in  (i_instr[11:4]),
        .o_out (w_imm8)
    );

    // Type D: 12bit immediate from bits [15:4] (blt, bz)
    imm_gen_ext_12to16 u_ext12 (
        .i_in  (i_instr[15:4]),
        .o_out (w_imm12)
    );

    // Selection based on instruction format
    imm_gen_mux_4to1_16bit u_mux (
        .i_sel (i_imm_sel),
        .i_in0 (w_imm4_type_a),
        .i_in1 (w_imm4_type_b),
        .i_in2 (w_imm8),
        .i_in3 (w_imm12),
        .o_out (o_imm)
    );

endmodule