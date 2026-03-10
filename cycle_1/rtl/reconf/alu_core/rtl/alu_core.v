module alu_core (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_alu_op,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_add_sub_res;
    wire [15:0] w_and_res;
    wire [15:0] w_or_res;
    wire [15:0] w_xor_res;
    wire [15:0] w_not_res;
    wire [15:0] w_sra_res;
    wire [15:0] w_sla_res;
    wire        w_adder_v;
    wire        w_sub_en;
    wire [2:0]  w_mux_sel;

    // 減算有効信号: opcodeが0001(sub)の時に減算モードとする
    assign w_sub_en = (i_alu_op == 4'b0001);

    // 演算結果選択信号の修正:
    // LOAD(1010), STORE(1011), ADDI(1000) などの I-type/Memory命令 (MSBが1) の場合、
    // アドレス計算や加算を行うために、強制的に加算結果(000)を選択するように制御する。
    // これにより、LOAD命令時に誤って論理演算(AND等)の結果が出力されるのを防ぐ。
    assign w_mux_sel = (i_alu_op[3]) ? 3'b000 : i_alu_op[2:0];

    // 1. 算術演算ユニット (加減算)
    alu_core_adder_sub_16bit u_adder_sub (
        .i_a      (i_a),
        .i_b      (i_b),
        .i_sub_en (w_sub_en),
        .o_sum    (w_add_sub_res),
        .o_v_flag (w_adder_v)
    );

    // 2. 論理演算ユニット (AND, OR, XOR, NOT)
    alu_core_logic_unit_16bit u_logic (
        .i_a   (i_a),
        .i_b   (i_b),
        .o_and (w_and_res),
        .o_or  (w_or_res),
        .o_xor (w_xor_res),
        .o_not (w_not_res)
    );

    // 3. シフト演算ユニット (SRA, SLA)
    alu_core_shifter_16bit u_shifter (
        .i_a   (i_a),
        .i_b   (i_b),
        .o_sra (w_sra_res),
        .o_sla (w_sla_res)
    );

    // 4. 結果選択マルチプレクサ
    // 命令に基づき生成された w_mux_sel を使用して、最終的な演算結果を出力
    alu_core_result_mux_16bit u_res_mux (
        .i_sel (w_mux_sel),
        .i_d0  (w_add_sub_res), // 000: add / I-type / Memory addr calculation
        .i_d1  (w_add_sub_res), // 001: sub
        .i_d2  (w_and_res),     // 010: and
        .i_d3  (w_or_res),      // 011: or
        .i_d4  (w_xor_res),     // 100: xor
        .i_d5  (w_not_res),     // 101: not
        .i_d6  (w_sra_res),     // 110: sra
        .i_d7  (w_sla_res),     // 111: sla
        .o_data(o_result)
    );

    // 5. フラグ生成
    assign o_flag_z = (o_result == 16'h0000);
    assign o_flag_n = o_result[15];
    assign o_flag_v = w_adder_v;

endmodule