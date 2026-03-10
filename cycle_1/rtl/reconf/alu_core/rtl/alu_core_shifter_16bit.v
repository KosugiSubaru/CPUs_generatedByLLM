module alu_core_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sra,
    output wire [15:0] o_sla
);

    // 算術右シフト (SRA: Shift Right Arithmetic)
    // $signedにより符号ビット（MSB）を維持したままシフトを行う
    // シフト量は下位4ビット（0-15）を使用
    assign o_sra = $signed(i_a) >>> i_b[3:0];

    // 算術左シフト (SLA: Shift Left Arithmetic)
    // 2の補数表現における算術左シフトは、論理左シフトと同様に下位ビットに0を挿入する
    assign o_sla = i_a << i_b[3:0];

endmodule