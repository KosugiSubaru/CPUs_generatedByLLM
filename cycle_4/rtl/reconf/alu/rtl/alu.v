module alu (
    input  wire [15:0] i_rs1,
    input  wire [15:0] i_rs2,
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_rd,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_adder_res;
    wire        w_adder_cout;
    wire [15:0] w_logic_res;
    wire [15:0] w_shift_res;
    wire        w_is_sub;

    // 減算命令(0001)の判定
    assign w_is_sub = (i_opcode == 4'b0001);

    // 算術演算ユニット (加減算、アドレス計算用)
    alu_adder_16bit u_adder (
        .i_a    (i_rs1),
        .i_b    (i_rs2),
        .i_sub  (w_is_sub),
        .o_sum  (w_adder_res),
        .o_cout (w_adder_cout)
    );

    // 論理演算ユニット
    alu_logic_16bit u_logic (
        .i_a   (i_rs1),
        .i_b   (i_rs2),
        .i_op  (i_opcode),
        .o_out (w_logic_res)
    );

    // シフト演算ユニット
    alu_shifter_16bit u_shifter (
        .i_a   (i_rs1),
        .i_b   (i_rs2),
        .i_op  (i_opcode),
        .o_out (w_shift_res)
    );

    // 最終演算結果の選択 (MUX)
    assign o_rd = (i_opcode == 4'b0000 || i_opcode == 4'b0001 || i_opcode == 4'b1000 || 
                   i_opcode == 4'b1010 || i_opcode == 4'b1011 || i_opcode == 4'b1111) ? w_adder_res :
                  (i_opcode >= 4'b0010 && i_opcode <= 4'b0101) ? w_logic_res :
                  (i_opcode == 4'b0110 || i_opcode == 4'b0111) ? w_shift_res :
                  (i_opcode == 4'b1001) ? i_rs2 : // loadi (即値をそのまま出力)
                  16'h0000;

    // フラグ生成ユニット
    alu_flag_gen u_flag_gen (
        .i_rd     (o_rd),
        .i_rs1    (i_rs1),
        .i_rs2    (i_rs2),
        .i_opcode (i_opcode),
        .o_flag_z (o_flag_z),
        .o_flag_n (o_flag_n),
        .o_flag_v (o_flag_v)
    );

endmodule