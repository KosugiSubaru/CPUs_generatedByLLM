module alu_core_arithmetic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub, // 0: ADD, 1: SUB
    output wire [15:0] o_sum,
    output wire        o_v    // オーバーフローフラグ
);

    wire [15:0] w_b_mod;
    wire [16:0] w_carry;
    wire        w_v_add;
    wire        w_v_sub;

    // 減算時はBの各ビットを反転
    assign w_b_mod = i_b ^ {16{i_sub}};

    // キャリー入力の初期値（減算時は +1 するために1を入力）
    assign w_carry[0] = i_sub;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            alu_core_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // ISA定義に基づくオーバーフロー判定
    // 加算時: (A[15]==1 & B[15]==1 & Sum[15]==0) | (A[15]==0 & B[15]==0 & Sum[15]==1)
    assign w_v_add = (i_a[15] & i_b[15] & ~o_sum[15]) | (~i_a[15] & ~i_b[15] & o_sum[15]);

    // 減算時: (A[15]==0 & B[15]==1 & Sum[15]==1) | (A[15]==1 & B[15]==0 & Sum[15]==0)
    assign w_v_sub = (~i_a[15] & i_b[15] & o_sum[15]) | (i_a[15] & ~i_b[15] & ~o_sum[15]);

    // 演算モードに応じてVフラグを選択
    assign o_v = i_sub ? w_v_sub : w_v_add;

endmodule