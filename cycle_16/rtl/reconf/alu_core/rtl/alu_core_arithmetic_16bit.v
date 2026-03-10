module alu_core_arithmetic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub_en,
    output wire [15:0] o_sum,
    output wire        o_v
);

    wire [15:0] w_b_mod;
    wire [16:0] w_carry;
    wire        w_v_add;
    wire        w_v_sub;

    // 減算時は入力を反転し、最下位ビットへのキャリーインを1にする（2の補数）
    assign w_carry[0] = i_sub_en;
    assign w_b_mod    = i_b ^ {16{i_sub_en}};

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            alu_core_full_adder u_full_adder (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // ISA定義に基づくオーバーフロー判定
    // 加算時: 正+正=負、または負+負=正となった場合
    assign w_v_add = (~i_a[15] & ~i_b[15] &  o_sum[15]) | (i_a[15] &  i_b[15] & ~o_sum[15]);

    // 減算時: 正-負=負、または負-正=正となった場合
    assign w_v_sub = (~i_a[15] &  i_b[15] &  o_sum[15]) | (i_a[15] & ~i_b[15] & ~o_sum[15]);

    // 命令(sub_en)に応じてフラグを選択
    assign o_v = i_sub_en ? w_v_sub : w_v_add;

endmodule