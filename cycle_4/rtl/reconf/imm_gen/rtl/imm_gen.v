module imm_gen (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_sel,
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_ext4;
    wire [15:0] w_imm_ext8;
    wire [15:0] w_imm_ext12;
    wire [15:0] w_imm_ext4h;

    imm_gen_ext4 u_ext4 (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext4)
    );

    imm_gen_ext8 u_ext8 (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext8)
    );

    imm_gen_ext12 u_ext12 (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext12)
    );

    imm_gen_ext4h u_ext4h (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext4h)
    );

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_imm_mux
            imm_gen_mux_1bit u_mux (
                .i_sel (i_imm_sel),
                .i_d0  (w_imm_ext4[i]),
                .i_d1  (w_imm_ext8[i]),
                .i_d2  (w_imm_ext12[i]),
                .i_d3  (w_imm_ext4h[i]),
                .o_q   (o_imm[i])
            );
        end
    endgenerate

endmodule