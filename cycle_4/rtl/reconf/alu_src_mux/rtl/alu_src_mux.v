module alu_src_mux (
    input  wire        i_alu_src,
    input  wire [15:0] i_rs2_data,
    input  wire [15:0] i_imm_data,
    output wire [15:0] o_alu_op2
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_alu_src_mux
            alu_src_mux_bit u_mux_bit (
                .i_sel (i_alu_src),
                .i_d0  (i_rs2_data[i]),
                .i_d1  (i_imm_data[i]),
                .o_q   (o_alu_op2[i])
            );
        end
    endgenerate

endmodule