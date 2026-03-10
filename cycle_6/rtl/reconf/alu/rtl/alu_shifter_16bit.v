module alu_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_op, // 0: SRA, 1: SLA
    output wire [15:0] o_y
);

    wire [3:0]  w_shamt;
    wire [15:0] w_sra_result;
    wire [15:0] w_sla_result;

    // シフト量は下位4ビット（0〜15）を使用
    assign w_shamt = i_b[3:0];

    // 算術右シフト (SRA): 最上位ビット（符号ビット）を維持して右へ移動
    assign w_sra_result = $signed(i_a) >>> w_shamt;

    // 算術左シフト (SLA): 0を充填して左へ移動
    assign w_sla_result = i_a << w_shamt;

    // 演算選択：i_op(alu_op[0]) が 0 なら SRA、1 なら SLA を選択
    assign o_y = (i_op == 1'b0) ? w_sra_result : w_sla_result;

endmodule