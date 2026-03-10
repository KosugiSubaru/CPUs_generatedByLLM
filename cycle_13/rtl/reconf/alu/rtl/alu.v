module alu (
    input  wire [3:0]  i_opcode,
    input  wire [15:0] i_rs1_data,
    input  wire [15:0] i_rs2_data,
    output wire [15:0] o_alu_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_add_res;
    wire [15:0] w_and_res;
    wire [15:0] w_or_res;
    wire [15:0] w_xor_res;
    wire [15:0] w_not_res;
    wire [15:0] w_shift_res;
    wire        w_adder_v;
    wire        w_adder_cout;
    wire [2:0]  w_mux_sel;
    wire        w_is_sub;

    // 算術演算ユニットの加減算切り替え制御
    // store命令(1011)の際、i_opcode[0]が1であるために減算が行われていた問題を修正。
    // R-typeのsubtraction(0001)の時のみ減算モード(i_is_sub=1)とする。
    assign w_is_sub = (i_opcode == 4'b0001);

    // 算術演算ユニット：加算(0000, 1000, 1010, 1011)および減算(0001)を実行
    alu_adder_16bit u_adder (
        .i_a      (i_rs1_data),
        .i_b      (i_rs2_data),
        .i_is_sub (w_is_sub),
        .o_sum    (w_add_res),
        .o_v      (w_adder_v),
        .o_cout   (w_adder_cout)
    );

    // 論理演算ユニット：AND, OR, XOR, NOTを並列実行
    alu_logic_16bit u_logic (
        .i_a   (i_rs1_data),
        .i_b   (i_rs2_data),
        .o_and (w_and_res),
        .o_or  (w_or_res),
        .o_xor (w_xor_res),
        .o_not (w_not_res)
    );

    // シフト演算ユニット：SRA(0110), SLA(0111)を実行
    alu_shifter_16bit u_shifter (
        .i_data    (i_rs1_data),
        .i_shamt   (i_rs2_data[3:0]),
        .i_is_left (i_opcode[0]),
        .o_data    (w_shift_res)
    );

    // 演算結果選択：opcodeのビット構成に基づきMUXの選択信号を生成
    // 基本的にi_opcode[2:0]を使用するが、メモリアクセス(1010, 1011)時は加算(000)を選択
    assign w_mux_sel = (i_opcode[3] == 1'b1 && i_opcode[1] == 1'b1) ? 3'b000 : i_opcode[2:0];

    alu_mux8_16bit u_result_mux (
        .i_sel  (w_mux_sel),
        .i_d0   (w_add_res),   // Add
        .i_d1   (w_add_res),   // Sub (Adder側ですでに計算済み)
        .i_d2   (w_and_res),   // AND
        .i_d3   (w_or_res),    // OR
        .i_d4   (w_xor_res),   // XOR
        .i_d5   (w_not_res),   // NOT
        .i_d6   (w_shift_res), // SRA
        .i_d7   (w_shift_res), // SLA
        .o_data (o_alu_result)
    );

    // フラグ生成
    assign o_flag_z = (o_alu_result == 16'b0);
    assign o_flag_n = o_alu_result[15];
    assign o_flag_v = w_adder_v;

endmodule