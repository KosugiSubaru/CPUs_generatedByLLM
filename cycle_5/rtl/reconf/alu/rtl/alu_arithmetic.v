module alu_arithmetic (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_mode,   // 0: addition, 1: subtraction
    output wire [15:0] o_res,
    output wire        o_flag_v
);

    // 減算時にはBの入力をビット反転し、アダーのキャリーインに1を入力することで2の補数を作る
    wire [15:0] w_b_in;
    assign w_b_in = i_b ^ {16{i_mode}};

    // 16ビットアダーのインスタンス化
    alu_adder_nbit u_adder (
        .i_a    (i_a),
        .i_b    (w_b_in),
        .i_cin  (i_mode),
        .o_sum  (o_res)
    );

    // オーバーフローフラグ(V)の生成
    // ISA定義の条件式に基づき、加算時と減算時で論理を切り替える
    wire w_v_add;
    wire w_v_sub;

    // Addition V: (rs1[15]==1 & rs2[15]==1 & rd[15]==0) | (rs1[15]==0 & rs2[15]==0 & rd[15]==1)
    assign w_v_add = (i_a[15] == 1'b1 && i_b[15] == 1'b1 && o_res[15] == 1'b0) ||
                     (i_a[15] == 1'b0 && i_b[15] == 1'b0 && o_res[15] == 1'b1);

    // Subtraction V: (rs1[15]==0 & rs2[15]==1 & rd[15]==1) | (rs1[15]==1 & rs2[15]==0 & rd[15]==0)
    assign w_v_sub = (i_a[15] == 1'b0 && i_b[15] == 1'b1 && o_res[15] == 1'b1) ||
                     (i_a[15] == 1'b1 && i_b[15] == 1'b0 && o_res[15] == 1'b0);

    assign o_flag_v = (i_mode == 1'b0) ? w_v_add : w_v_sub;

endmodule