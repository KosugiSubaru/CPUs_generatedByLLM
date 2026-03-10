module alu_shifter_16bit (
    input  wire [15:0] i_data,
    input  wire [3:0]  i_shamt,
    output wire [15:0] o_sra,
    output wire [15:0] o_sla
);

    // 算術右シフト (SRA: Shift Right Arithmetic)
    // 符号付き(signed)として扱うことで、最上位ビット(符号ビット)を維持しながら右へシフトする
    // 回路図上では、符号ビットが空いたスロットへコピーされる配線として視覚化される
    assign o_sra = $signed(i_data) >>> i_shamt;

    // 算術左シフト (SLA: Shift Left Arithmetic)
    // 下位ビットを0で埋めながら左へシフトする
    // 論理左シフト(SLL)とビットパターン上の結果は同じだが、ISA上の算術演算としての意図を表現する
    assign o_sla = i_data << i_shamt;

endmodule