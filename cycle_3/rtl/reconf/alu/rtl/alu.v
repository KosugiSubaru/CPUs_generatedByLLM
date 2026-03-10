module alu (
    input  wire [15:0] i_rs1_data,
    input  wire [15:0] i_rs2_data,
    input  wire [3:0]  i_alu_op,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0]  w_res_adder;
    wire [15:0]  w_res_and;
    wire [15:0]  w_res_or;
    wire [15:0]  w_res_xor;
    wire [15:0]  w_res_not;
    wire [15:0]  w_res_sra;
    wire [15:0]  w_res_sla;
    wire [255:0] w_mux_inputs;

    // 加減算器ユニット (ADD, SUB, ADDI, LOAD, STORE)
    // エラー修正: 定義されている o_cout ポートを明示的に未接続として記述
    alu_adder_16bit u_adder (
        .i_a      (i_rs1_data),
        .i_b      (i_rs2_data),
        .i_is_sub (i_alu_op == 4'b0001),
        .o_sum    (w_res_adder),
        .o_cout   () 
    );

    // 論理演算ユニット (AND, OR, XOR, NOT)
    alu_logic_16bit u_logic (
        .i_a     (i_rs1_data),
        .i_b     (i_rs2_data),
        .o_and   (w_res_and),
        .o_or    (w_res_or),
        .o_xor   (w_res_xor),
        .o_not   (w_res_not)
    );

    // シフト演算ユニット (SRA, SLA)
    alu_shifter_16bit u_shifter (
        .i_data  (i_rs1_data),
        .i_shamt (i_rs2_data[3:0]),
        .o_sra   (w_res_sra),
        .o_sla   (w_res_sla)
    );

    // 演算結果選択用マトリクスの構成
    assign w_mux_inputs[15:0]    = w_res_adder;
    assign w_mux_inputs[31:16]   = w_res_adder;
    assign w_mux_inputs[47:32]   = w_res_and;
    assign w_mux_inputs[63:48]   = w_res_or;
    assign w_mux_inputs[79:64]   = w_res_xor;
    assign w_mux_inputs[95:80]   = w_res_not;
    assign w_mux_inputs[111:96]  = w_res_sra;
    assign w_mux_inputs[127:112] = w_res_sla;
    assign w_mux_inputs[143:128] = w_res_adder;
    assign w_mux_inputs[159:144] = i_rs2_data;
    assign w_mux_inputs[255:160] = 96'h0;

    // 演算結果の最終選択
    alu_mux_16to1_16bit u_res_mux (
        .i_data (w_mux_inputs),
        .i_sel  (i_alu_op),
        .o_q    (o_result)
    );

    // フラグ判定ロジック
    alu_flag_logic u_flags (
        .i_op     (i_alu_op),
        .i_src1   (i_rs1_data),
        .i_src2   (i_rs2_data),
        .i_result (o_result),
        .o_z      (o_flag_z),
        .o_n      (o_flag_n),
        .o_v      (o_flag_v)
    );

endmodule