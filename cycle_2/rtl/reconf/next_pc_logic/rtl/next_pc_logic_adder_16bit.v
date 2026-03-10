module next_pc_logic_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);

    wire [16:0] w_carry;

    // 初期キャリー入力は0（単純加算用）
    assign w_carry[0] = 1'b0;

    genvar i;

    // generate文を用いて16ビット分全加算器を接続
    // 回路図上でキャリーの伝搬が視覚化されるRipple Carry Adder構造
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_adder
            next_pc_logic_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule