module alu_core_shifter_16bit (
    input  wire [15:0] i_a,         // シフト対象データ (rs1)
    input  wire [15:0] i_b,         // シフト量 (rs2)
    input  wire        i_right,     // 1: 右シフト(SRA), 0: 左シフト(SLA)
    output wire [15:0] o_out
);

    wire [3:0]  w_shamt;
    wire [15:0] w_sra_res;
    wire [15:0] w_sla_res;

    // 16ビット幅に対する有効なシフト量は 0-15 (4ビット)
    assign w_shamt = i_b[3:0];

    // 算術右シフト (SRA)
    // $signed を使用することで符号ビットの拡張を維持する配線として合成される
    assign w_sra_res = $unsigned($signed(i_a) >>> w_shamt);

    // 算術左シフト (SLA)
    // 論理左シフトと同様の配線構造を持つ
    assign w_sla_res = i_a << w_shamt;

    // 演算種別に基づき結果を選択
    assign o_out = (i_right) ? w_sra_res : w_sla_res;

endmodule