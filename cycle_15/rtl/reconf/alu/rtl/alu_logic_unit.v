module alu_logic_unit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_res_and,
    output wire [15:0] o_res_or,
    output wire [15:0] o_res_xor,
    output wire [15:0] o_res_not
);

    genvar i;

    // generate文を用いて、ビットごとの論理演算を16ビット並列に配置する
    // これにより、論理合成後の回路図において並列なゲート構造が視覚化される
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_bitwise
            assign o_res_and[i] = i_a[i] & i_b[i];
            assign o_res_or[i]  = i_a[i] | i_b[i];
            assign o_res_xor[i] = i_a[i] ^ i_b[i];
            assign o_res_not[i] = ~i_a[i];
        end
    endgenerate

endmodule