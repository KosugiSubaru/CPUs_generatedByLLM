module alu (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_alu_op,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_adder_res;
    wire [15:0] w_logic_res;
    wire [15:0] w_shifter_res;
    wire        w_adder_v;

    // 加減算・アドレス計算ユニット (addi等も含む)
    alu_adder_16bit u_alu_adder_16bit (
        .i_a      (i_a),
        .i_b      (i_b),
        .i_is_sub (i_alu_op[0] & ~i_alu_op[3]),
        .o_sum    (w_adder_res),
        .o_v      (w_adder_v)
    );

    // 論理演算ユニット (AND, OR, XOR, NOT)
    alu_logic_16bit u_alu_logic_16bit (
        .i_a   (i_a),
        .i_b   (i_b),
        .i_op  (i_alu_op[2:0]),
        .o_res (w_logic_res)
    );

    // シフト演算ユニット (SRA, SLA)
    alu_shifter_16bit u_alu_shifter_16bit (
        .i_a       (i_a),
        .i_b       (i_b[3:0]),
        .i_is_left (i_alu_op[0]),
        .o_res     (w_shifter_res)
    );

    // 最終結果選択マルチプレクサ
    alu_mux_out_16bit u_alu_mux_out_16bit (
        .i_sel     (i_alu_op),
        .i_adder   (w_adder_res),
        .i_logic   (w_logic_res),
        .i_shifter (w_shifter_res),
        .i_pass_b  (i_b),
        .o_res     (o_result)
    );

    // フラグ生成
    assign o_flag_z = (o_result == 16'h0000);
    assign o_flag_n = o_result[15];
    // 加算、減算、addiの時のみ有効なVフラグを出力
    assign o_flag_v = ((i_alu_op == 4'b0000) || (i_alu_op == 4'b0001) || (i_alu_op == 4'b1000)) ? w_adder_v : 1'b0;

endmodule