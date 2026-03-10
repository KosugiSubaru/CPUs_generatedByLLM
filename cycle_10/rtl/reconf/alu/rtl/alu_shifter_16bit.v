module alu_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_op, // 0: SRA, 1: SLA
    output wire [15:0] o_res
);

    wire [3:0]  w_shamt;
    wire [15:0] w_sra_st1;
    wire [15:0] w_sra_final;
    wire [15:0] w_sla_st1;
    wire [15:0] w_sla_final;

    assign w_shamt = i_b[3:0];

    // --- Arithmetic Right Shift (SRA) Logic ---
    // Stage 1: 0, 1, 2, 3ビットシフト
    alu_mux_4to1 u_mux_sra_st1 (
        .i_data0 (i_a),
        .i_data1 ({i_a[15], i_a[15:1]}),
        .i_data2 ({{2{i_a[15]}}, i_a[15:2]}),
        .i_data3 ({{3{i_a[15]}}, i_a[15:3]}),
        .i_sel   (w_shamt[1:0]),
        .o_data  (w_sra_st1)
    );

    // Stage 2: 0, 4, 8, 12ビットシフト
    alu_mux_4to1 u_mux_sra_st2 (
        .i_data0 (w_sra_st1),
        .i_data1 ({{4{w_sra_st1[15]}}, w_sra_st1[15:4]}),
        .i_data2 ({{8{w_sra_st1[15]}}, w_sra_st1[15:8]}),
        .i_data3 ({{12{w_sra_st1[15]}}, w_sra_st1[15:12]}),
        .i_sel   (w_shamt[3:2]),
        .o_data  (w_sra_final)
    );

    // --- Arithmetic Left Shift (SLA) Logic ---
    // Stage 1: 0, 1, 2, 3ビットシフト
    alu_mux_4to1 u_mux_sla_st1 (
        .i_data0 (i_a),
        .i_data1 ({i_a[14:0], 1'b0}),
        .i_data2 ({i_a[13:0], 2'b0}),
        .i_data3 ({i_a[12:0], 3'b0}),
        .i_sel   (w_shamt[1:0]),
        .o_data  (w_sla_st1)
    );

    // Stage 2: 0, 4, 8, 12ビットシフト
    alu_mux_4to1 u_mux_sla_st2 (
        .i_data0 (w_sla_st1),
        .i_data1 ({w_sla_st1[11:0], 4'b0}),
        .i_data2 ({w_sla_st1[7:0],  8'b0}),
        .i_data3 ({w_sla_st1[3:0],  12'b0}),
        .i_sel   (w_shamt[3:2]),
        .o_data  (w_sla_final)
    );

    // 最終出力の選択 (0: SRA, 1: SLA)
    assign o_res = (i_op == 1'b0) ? w_sra_final : w_sla_final;

endmodule