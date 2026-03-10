module alu (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_alu_op,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_add_sub_result;
    wire [15:0] w_logic_result;
    wire [15:0] w_shift_result;
    wire        w_adder_sub_en;
    wire        w_adder_cout;

    // 1. 算術演算ユニット (Addition / Subtraction)
    // opcode: 0000(add), 0001(sub), 1000(addi), 1010(load), 1011(store)
    assign w_adder_sub_en = (i_alu_op == 4'b0001);

    alu_adder_16bit u_adder (
        .i_a    (i_a),
        .i_b    (i_b),
        .i_sub  (w_adder_sub_en),
        .o_sum  (w_add_sub_result),
        .o_cout (w_adder_cout)
    );

    // 2. 論理演算ユニット (AND, OR, XOR, NOT)
    // opcode: 0010, 0011, 0100, 0101
    alu_logical_unit_16bit u_logical (
        .i_a      (i_a),
        .i_b      (i_b),
        .i_alu_op (i_alu_op),
        .o_result (w_logic_result)
    );

    // 3. シフト演算ユニット (SRA, SLA)
    // opcode: 0110, 0111
    alu_shifter_16bit u_shifter (
        .i_a      (i_a),
        .i_b      (i_b),
        .i_alu_op (i_alu_op),
        .o_result (w_shift_result)
    );

    // 4. 演算結果の最終選択
    // 修正：元のコードでは (i_alu_op[3:2] == 2'b01) で判定していたため、
    // XOR(0100) や NOT(0101) までシフト演算器の結果が選択されてしまっていた。
    // シフト命令 (0110, 0111) のみを個別に指定することで、論理演算の結果が正しく出力されるように修正。
    assign o_result = (i_alu_op == 4'b0000 || i_alu_op == 4'b0001 || 
                       i_alu_op == 4'b1000 || i_alu_op == 4'b1010 || 
                       i_alu_op == 4'b1011) ? w_add_sub_result :
                      (i_alu_op == 4'b0110 || i_alu_op == 4'b0111) ? w_shift_result :
                      (i_alu_op == 4'b1001)    ? i_b : // loadi (Pass-through imm)
                                                 w_logic_result;

    // 5. ステータスフラグ生成
    alu_flag_generator u_flags (
        .i_rs1_data (i_a),
        .i_rs2_data (i_b),
        .i_rd_data  (o_result),
        .i_alu_op   (i_alu_op),
        .o_flag_z   (o_flag_z),
        .o_flag_n   (o_flag_n),
        .o_flag_v   (o_flag_v)
    );

endmodule