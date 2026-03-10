module alu_main_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [3:0]  i_shamt,
    input  wire        i_mode, // 0: SRA (Arithmetic Right), 1: SLA (Arithmetic Left)
    output wire [15:0] o_q
);

    // SRA (Arithmetic Right Shift) Stages
    wire [15:0] w_sra0, w_sra1, w_sra2, w_sra3;
    // SLA (Arithmetic Left Shift) Stages
    wire [15:0] w_sla0, w_sla1, w_sla2, w_sla3;

    genvar i;

    generate
        // --- SRA Logic Path ---
        // Stage 0: Shift by 1
        for (i = 0; i < 16; i = i + 1) begin : gen_sra_s0
            assign w_sra0[i] = i_shamt[0] ? ((i < 15) ? i_a[i+1] : i_a[15]) : i_a[i];
        end
        // Stage 1: Shift by 2
        for (i = 0; i < 16; i = i + 1) begin : gen_sra_s1
            assign w_sra1[i] = i_shamt[1] ? ((i < 14) ? w_sra0[i+2] : w_sra0[15]) : w_sra0[i];
        end
        // Stage 2: Shift by 4
        for (i = 0; i < 16; i = i + 1) begin : gen_sra_s2
            assign w_sra2[i] = i_shamt[2] ? ((i < 12) ? w_sra1[i+4] : w_sra1[15]) : w_sra1[i];
        end
        // Stage 3: Shift by 8
        for (i = 0; i < 16; i = i + 1) begin : gen_sra_s3
            assign w_sra3[i] = i_shamt[3] ? ((i < 8) ? w_sra2[i+8] : w_sra2[15]) : w_sra2[i];
        end

        // --- SLA Logic Path ---
        // Stage 0: Shift by 1
        for (i = 0; i < 16; i = i + 1) begin : gen_sla_s0
            assign w_sla0[i] = i_shamt[0] ? ((i > 0) ? i_a[i-1] : 1'b0) : i_a[i];
        end
        // Stage 1: Shift by 2
        for (i = 0; i < 16; i = i + 1) begin : gen_sla_s1
            assign w_sla1[i] = i_shamt[1] ? ((i > 1) ? w_sla0[i-2] : 1'b0) : w_sla0[i];
        end
        // Stage 2: Shift by 4
        for (i = 0; i < 16; i = i + 1) begin : gen_sla_s2
            assign w_sla2[i] = i_shamt[2] ? ((i > 3) ? w_sla1[i-4] : 1'b0) : w_sla1[i];
        end
        // Stage 3: Shift by 8
        for (i = 0; i < 16; i = i + 1) begin : gen_sla_s3
            assign w_sla3[i] = i_shamt[3] ? ((i > 7) ? w_sla2[i-8] : 1'b0) : w_sla2[i];
        end

        // Final Selection
        for (i = 0; i < 16; i = i + 1) begin : gen_shift_out
            assign o_q[i] = i_mode ? w_sla3[i] : w_sra3[i];
        end
    endgenerate

endmodule