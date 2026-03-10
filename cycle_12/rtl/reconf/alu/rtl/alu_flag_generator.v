module alu_flag_generator (
    input  wire [15:0] i_rs1_data,
    input  wire [15:0] i_rs2_data,
    input  wire [15:0] i_rd_data,  // ALU演算結果
    input  wire [3:0]  i_alu_op,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire w_is_sub;
    wire w_v_add;
    wire w_v_sub;

    // Zeroフラグ: 全ビットが0の場合に1
    assign o_flag_z = (i_rd_data == 16'h0000);

    // Negativeフラグ: 最上位ビット(符号ビット)が1の場合に1
    assign o_flag_n = i_rd_data[15];

    // 演算モードの判定 (0001: subtraction)
    assign w_is_sub = (i_alu_op == 4'b0001);

    // Overflowフラグ (Addition): 同符号の足し算で結果の符号が反転した場合
    assign w_v_add = ( (i_rs1_data[15] == 1'b1) && (i_rs2_data[15] == 1'b1) && (i_rd_data[15] == 1'b0) ) ||
                     ( (i_rs1_data[15] == 1'b0) && (i_rs2_data[15] == 1'b0) && (i_rd_data[15] == 1'b1) );

    // Overflowフラグ (Subtraction): 異符号の引き算で結果の符号が想定と異なる場合
    assign w_v_sub = ( (i_rs1_data[15] == 1'b0) && (i_rs2_data[15] == 1'b1) && (i_rd_data[15] == 1'b1) ) ||
                     ( (i_rs1_data[15] == 1'b1) && (i_rs2_data[15] == 1'b0) && (i_rd_data[15] == 1'b0) );

    // 演算の種類に応じてVフラグを選択
    assign o_flag_v = (w_is_sub) ? w_v_sub : w_v_add;

endmodule