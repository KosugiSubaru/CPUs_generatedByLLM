module alu_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_is_sub,
    output wire [15:0] o_sum,
    output wire        o_v,
    output wire        o_cout
);

    wire [16:0] w_carry;
    wire [15:0] w_b_mod;
    genvar i;

    // 減算の場合はBを反転し、最下位キャリー(i_is_sub)を1にすることで2の補数演算を行う
    assign w_carry[0] = i_is_sub;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_ripple_carry_adder
            assign w_b_mod[i] = i_b[i] ^ i_is_sub;

            alu_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    assign o_cout = w_carry[16];
    
    // 符号付きオーバーフローフラグ(V): 15bit目へのキャリーと16bit目へのキャリーの不一致で判定
    assign o_v = w_carry[15] ^ w_carry[16];

endmodule