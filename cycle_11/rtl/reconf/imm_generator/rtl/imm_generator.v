module imm_generator (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_sel,
    output wire [15:0] o_imm
);

    wire [15:0] w_imm4a;
    wire [15:0] w_imm4b;
    wire [15:0] w_imm8;
    wire [15:0] w_imm12;

    imm_generator_ext4a_16bit u_ext4a (
        .i_instr (i_instr),
        .o_imm   (w_imm4a)
    );

    imm_generator_ext4b_16bit u_ext4b (
        .i_instr (i_instr),
        .o_imm   (w_imm4b)
    );

    imm_generator_ext8_16bit u_ext8 (
        .i_instr (i_instr),
        .o_imm   (w_imm8)
    );

    imm_generator_ext12_16bit u_ext12 (
        .i_instr (i_instr),
        .o_imm   (w_imm12)
    );

    imm_generator_mux_4to1_16bit u_mux (
        .i_sel (i_imm_sel),
        .i_d0  (w_imm4a),
        .i_d1  (w_imm4b),
        .i_d2  (w_imm8),
        .i_d3  (w_imm12),
        .o_y   (o_imm)
    );

endmodule