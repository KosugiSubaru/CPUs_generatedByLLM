module alu_shifter (
    input  wire [15:0] i_a,      // シフト対象データ (rs1)
    input  wire [15:0] i_b,      // シフト量 (rs2の下位ビットを使用)
    input  wire [3:0]  i_alu_op, // ALU演算種別信号
    output wire [15:0] o_res      // シフト演算結果
);

    // 16ビットデータのシフト量は0〜15であるため、下位4ビットを抽出
    wire [3:0] w_shamt;
    assign w_shamt = i_b[3:0];

    // 0110: SRA (算術右シフト), 0111: SLA (算術左シフト)
    // $signed() キャストを使用することで、>>> 演算子による符号拡張（算術シフト）を明示
    assign o_res = (i_alu_op == 4'b0110) ? ($signed(i_a) >>> w_shamt) :
                   (i_alu_op == 4'b0111) ? (i_a << w_shamt) :
                   16'h0000;

endmodule