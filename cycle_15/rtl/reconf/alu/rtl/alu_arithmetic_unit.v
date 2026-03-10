module alu_arithmetic_unit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_res_add,
    output wire [15:0] o_res_sub
);

    wire [15:0] w_b_inv;

    // 減算用の入力反転ロジック (~B)
    assign w_b_inv = ~i_b;

    // パタン構造化の観点から、加算用と減算用のデータパスを独立してインスタンス化
    // これにより、RTLビューアで加算器と減算器（反転器付き加算器）の構成が視覚化される
    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_arith_adders
            if (i == 0) begin : gen_add
                // 加算: A + B + 0
                alu_adder_16bit u_adder_add (
                    .i_a    (i_a),
                    .i_b    (i_b),
                    .i_cin  (1'b0),
                    .o_sum  (o_res_add),
                    .o_cout ()
                );
            end else begin : gen_sub
                // 減算: A + (~B) + 1 (2の補数を利用)
                alu_adder_16bit u_adder_sub (
                    .i_a    (i_a),
                    .i_b    (w_b_inv),
                    .i_cin  (1'b1),
                    .o_sum  (o_res_sub),
                    .o_cout ()
                );
            end
        end
    endgenerate

endmodule