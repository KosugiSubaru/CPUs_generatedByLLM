module alu_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [3:0]  i_b, // シフト量は下位4ビットを使用
    output wire [15:0] o_sra,
    output wire [15:0] o_sla
);

    // 算術右シフト (SRA): 符号ビットを維持して右へシフト
    // Verilogの >>> 演算子は型がsignedの場合に符号拡張を行う
    assign o_sra = $signed(i_a) >>> i_b;

    // 算術左シフト (SLA): 右側に0を挿入して左へシフト
    // 16ビットの算術左シフトは論理左シフト(<<)と結果が等しい
    assign o_sla = i_a << i_b;

endmodule