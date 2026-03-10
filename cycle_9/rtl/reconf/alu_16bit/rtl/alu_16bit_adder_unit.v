module alu_16bit_adder_unit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub_ctrl,
    output wire [15:0] o_sum,
    output wire        o_v
);

    wire [15:0] w_b_mod;
    wire [4:0]  w_c;
    wire        w_v_add;
    wire        w_v_sub;
    genvar i;

    // 減算時はBを反転し、最下位キャリーインを1にする(2の補数)
    assign w_b_mod = i_b ^ {16{i_sub_ctrl}};
    assign w_c[0]  = i_sub_ctrl;

    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_adder4
            alu_16bit_adder_4bit u_alu_16bit_adder_4bit (
                .i_a    (i_a[i*4 +: 4]),
                .i_b    (w_b_mod[i*4 +: 4]),
                .i_cin  (w_c[i]),
                .o_sum  (o_sum[i*4 +: 4]),
                .o_cout (w_c[i+1])
            );
        end
    endgenerate

    // ISA定義に基づくオーバーフローフラグ生成
    assign w_v_add = (i_a[15] == 1'b1 && i_b[15] == 1'b1 && o_sum[15] == 1'b0) ||
                     (i_a[15] == 1'b0 && i_b[15] == 1'b0 && o_sum[15] == 1'b1);

    assign w_v_sub = (i_a[15] == 1'b0 && i_b[15] == 1'b1 && o_sum[15] == 1'b1) ||
                     (i_a[15] == 1'b1 && i_b[15] == 1'b0 && o_sum[15] == 1'b0);

    assign o_v = (i_sub_ctrl) ? w_v_sub : w_v_add;

endmodule