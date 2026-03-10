module alu_16bit_shift_unit (
    input  wire [15:0] i_a,
    input  wire [3:0]  i_b,
    output wire [15:0] o_sra,
    output wire [15:0] o_sla
);

    // 算術右シフト (SRA): 符号ビットを維持してシフト
    assign o_sra = $signed(i_a) >>> i_b;

    // 算術左シフト (SLA): 下位に0を挿入してシフト（論理左シフトと同等）
    assign o_sla = i_a << i_b;

endmodule