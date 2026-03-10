module imm_generator_ext8_16bit (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire w_sign_bit;
    assign w_sign_bit = i_instr[11];

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_lower_bits
            assign o_imm[i] = i_instr[i + 4];
        end
        for (i = 8; i < 16; i = i + 1) begin : gen_sign_ext
            assign o_imm[i] = w_sign_bit;
        end
    endgenerate

endmodule