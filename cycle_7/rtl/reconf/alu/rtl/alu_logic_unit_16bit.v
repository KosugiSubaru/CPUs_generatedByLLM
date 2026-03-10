module alu_logic_unit_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_and,
    output wire [15:0] o_or,
    output wire [15:0] o_xor,
    output wire [15:0] o_not
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_bits
            assign o_and[i] = i_a[i] & i_b[i];
            assign o_or[i]  = i_a[i] | i_b[i];
            assign o_xor[i] = i_a[i] ^ i_b[i];
            assign o_not[i] = ~i_a[i];
        end
    endgenerate

endmodule