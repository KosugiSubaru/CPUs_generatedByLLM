module alu_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_sum;
    wire [15:0] w_and;
    wire [15:0] w_or;
    wire [15:0] w_xor;
    wire [15:0] w_not;
    wire [15:0] w_sra;
    wire [15:0] w_sla;
    wire        w_v_adder;

    // 算術演算ユニット (加算・減算)
    // opcode[0]を減算制御信号として使用 (0:add, 1:sub)
    alu_16bit_adder_unit u_alu_16bit_adder_unit (
        .i_a        (i_a),
        .i_b        (i_b),
        .i_sub_ctrl (i_opcode[0]),
        .o_sum      (w_sum),
        .o_v        (w_v_adder)
    );

    // 論理演算ユニット
    alu_16bit_logic_unit u_alu_16bit_logic_unit (
        .i_a   (i_a),
        .i_b   (i_b),
        .o_and (w_and),
        .o_or  (w_or),
        .o_xor (w_xor),
        .o_not (w_not)
    );

    // シフト演算ユニット
    alu_16bit_shift_unit u_alu_16bit_shift_unit (
        .i_a   (i_a),
        .i_b   (i_b[3:0]),
        .o_sra (w_sra),
        .o_sla (w_sla)
    );

    // 最終出力の選択
    // adder_unitは加減算両方をw_sumとして出力するため、i_data0とi_data1の両方に接続
    alu_16bit_mux8 u_alu_16bit_mux8 (
        .i_data0 (w_sum),
        .i_data1 (w_sum),
        .i_data2 (w_and),
        .i_data3 (w_or),
        .i_data4 (w_xor),
        .i_data5 (w_not),
        .i_data6 (w_sra),
        .i_data7 (w_sla),
        .i_sel   (i_opcode[2:0]),
        .o_data  (o_result)
    );

    // フラグ生成
    assign o_flag_z = (o_result == 16'h0000);
    assign o_flag_n = o_result[15];
    assign o_flag_v = w_v_adder;

endmodule