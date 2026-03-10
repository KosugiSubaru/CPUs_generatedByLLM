module imm_generator_ext4b_16bit (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire w_sign_bit;
    assign w_sign_bit = i_instr[15];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_lower_bits
            assign o_imm[i] = i_instr[i + 12];
        end
        for (i = 4; i < 16; i = i + 1) begin : gen_sign_ext
            assign o_imm[i] = w_sign_bit;
        end
    endgenerate

endmodule