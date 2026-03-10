module alu_unit_shifter_16bit (
    input  wire [15:0] i_data,
    input  wire [3:0]  i_shamt,
    output wire [15:0] o_sra,
    output wire [15:0] o_sla
);

    // 算術右シフト (SRA: Shift Right Arithmetic)
    // $signedにより最上位ビット(符号ビット)を維持してシフト
    assign o_sra = $signed(i_data) >>> i_shamt;

    // 算術左シフト (SLA: Shift Left Arithmetic)
    // 16ビット符号付き整数において、結果は論理左シフトと同等
    assign o_sla = i_data << i_shamt;

endmodule