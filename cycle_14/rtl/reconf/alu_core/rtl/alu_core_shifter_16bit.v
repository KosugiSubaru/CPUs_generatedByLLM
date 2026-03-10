module alu_core_shifter_16bit (
    input  wire [15:0] i_data,      // シフト対象データ (rs1)
    input  wire [3:0]  i_amount,    // シフト量 (rs2[3:0])
    input  wire [3:0]  i_opcode,    // 0110: SRA, 0111: SLA
    output wire [15:0] o_res
);

    // 算術右シフト (SRA) のバレルシフタ構造
    // 各ステージで 1, 2, 4, 8 ビットのシフトを選択
    wire [15:0] w_sra_st1 = i_amount[0] ? {i_data[15],    i_data[15:1]} : i_data;
    wire [15:0] w_sra_st2 = i_amount[1] ? {{2{i_data[15]}}, w_sra_st1[15:2]} : w_sra_st1;
    wire [15:0] w_sra_st3 = i_amount[2] ? {{4{i_data[15]}}, w_sra_st2[15:4]} : w_sra_st2;
    wire [15:0] w_sra_st4 = i_amount[3] ? {{8{i_data[15]}}, w_sra_st3[15:8]} : w_sra_st3;

    // 算術左シフト (SLA) のバレルシフタ構造
    // 各ステージで 1, 2, 4, 8 ビットのシフトを選択 (空いたビットは0埋め)
    wire [15:0] w_sla_st1 = i_amount[0] ? {i_data[14:0], 1'b0} : i_data;
    wire [15:0] w_sla_st2 = i_amount[1] ? {w_sla_st1[13:0], 2'b0} : w_sla_st1;
    wire [15:0] w_sla_st3 = i_amount[2] ? {w_sla_st2[11:0], 4'b0} : w_sla_st2;
    wire [15:0] w_sla_st4 = i_amount[3] ? {w_sla_st3[7:0],  8'b0} : w_sla_st3;

    // Opcode[0] により、右シフト(0)か左シフト(1)かを選択
    assign o_res = (i_opcode[0] == 1'b0) ? w_sra_st4 : w_sla_st4;

endmodule