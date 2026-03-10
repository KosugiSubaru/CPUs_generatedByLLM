module alu_core (
    input  wire [15:0] i_src1,      // 第一オペランド (rs1)
    input  wire [15:0] i_src2,      // 第二オペランド (rs2 or imm)
    input  wire [3:0]  i_opcode,    // 演算種別選択信号
    output wire [15:0] o_res,       // 演算結果
    output wire        o_flag_z,    // Zeroフラグ
    output wire        o_flag_n,    // Negativeフラグ
    output wire        o_flag_v     // Overflowフラグ
);

    // 内部接続ワイヤ
    wire [15:0] w_res_arith;
    wire [15:0] w_res_logic;
    wire [15:0] w_res_shift;
    wire        w_arith_v;
    wire        w_sub_en;

    // ISA定義: 減算命令(0001)の時のみ算術ユニットを減算モードにする
    assign w_sub_en = (i_opcode == 4'b0001);

    // 階層1: 算術演算ブロック (Addition/Subtraction)
    alu_core_arithmetic_16bit u_arith (
        .i_a      (i_src1),
        .i_b      (i_src2),
        .i_sub_en (w_sub_en),
        .o_res    (w_res_arith),
        .o_v      (w_arith_v)
    );

    // 階層1: 論理演算ブロック (AND/OR/XOR/NOT)
    alu_core_logical_16bit u_logic (
        .i_a      (i_src1),
        .i_b      (i_src2),
        .i_opcode (i_opcode),
        .o_res    (w_res_logic)
    );

    // 階層1: シフト演算ブロック (SRA/SLA)
    alu_core_shifter_16bit u_shift (
        .i_data   (i_src1),
        .i_amount (i_src2[3:0]), // 下位4bitをシフト量として使用
        .i_opcode (i_opcode),
        .o_res    (w_res_shift)
    );

    // 階層1: 最終結果選択マルチプレクサ
    // 算術、論理、シフト、および loadi (src2パススルー) から選択
    alu_core_res_mux_16bit u_res_mux (
        .i_sel       (i_opcode),
        .i_res_arith (w_res_arith),
        .i_res_logic (w_res_logic),
        .i_res_shift (w_res_shift),
        .i_res_imm   (i_src2),      // loadi(1001)用
        .o_res       (o_res)
    );

    // ステータスフラグ生成
    // ISA定義: rd[15]
    assign o_flag_n = o_res[15];
    
    // ISA定義: rd == 0
    assign o_flag_z = (o_res == 16'h0000);

    // ISA定義: 加減算器からのオーバーフロー信号
    assign o_flag_v = w_arith_v;

endmodule