module alu_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub,
    output wire [15:0] o_sum,
    output wire        o_v
);

    wire [16:0] w_carry;
    wire [15:0] w_b_mod;
    wire        w_v_add;
    wire        w_v_sub;

    // 減算時はBを反転し、最下位キャリー(i_sub)を1にすることで2の補数を作成
    assign w_carry[0] = i_sub;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            assign w_b_mod[i] = i_b[i] ^ i_sub;
            alu_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // ISA定義に基づいたオーバーフロー判定
    // 加算時: (A[15]==1 & B[15]==1 & Sum[15]==0) | (A[15]==0 & B[15]==0 & Sum[15]==1)
    assign w_v_add = (i_a[15] & w_b_mod[15] & ~o_sum[15]) | (~i_a[15] & ~w_b_mod[15] & o_sum[15]);
    
    // 減算時: (A[15]==0 & B[15]==1 & Sum[15]==1) | (A[15]==1 & B[15]==0 & Sum[15]==0)
    assign w_v_sub = (~i_a[15] & i_b[15] & o_sum[15]) | (i_a[15] & ~i_b[15] & ~o_sum[15]);

    assign o_v = (i_sub) ? w_v_sub : w_v_add;

endmodule